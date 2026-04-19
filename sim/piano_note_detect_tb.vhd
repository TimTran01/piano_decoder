library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.piano_note_tables_pkg.all;

entity piano_note_detect_tb is
end entity;

architecture tb of piano_note_detect_tb is
    constant CLK_PERIOD     : time := 10 ns;
    constant SAMPLE_RATE_HZ : real := 48000.0;

    constant FRAME_SIZE_G    : integer := 512;
    constant HOP_SIZE_G      : integer := 256;
    constant STABLE_FRAMES_G : integer := 1;

    constant REG_CONTROL       : natural := 16#00#;
    constant REG_STATUS        : natural := 16#04#;
    constant REG_PIANO_KEY     : natural := 16#08#;
    constant REG_MIDI          : natural := 16#0C#;
    constant REG_FREQUENCY     : natural := 16#10#;
    constant REG_LEVEL         : natural := 16#14#;
    constant REG_CENTS         : natural := 16#18#;
    constant REG_EVENT_COUNTER : natural := 16#1C#;

    constant A4_KEY : natural := 49;
    constant C5_KEY : natural := 52;
    constant CONTROL_CLEAR_EVENT : std_logic_vector(31 downto 0) := x"00000001";

    signal aclk                : std_logic := '0';
    signal aresetn             : std_logic := '0';
    signal sim_done            : std_logic := '0';
    signal s_axis_audio_tdata  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_axis_audio_tvalid : std_logic := '0';
    signal s_axis_audio_tready : std_logic;
    signal irq                 : std_logic;
    signal s_axi_awaddr        : std_logic_vector(4 downto 0) := (others => '0');
    signal s_axi_awprot        : std_logic_vector(2 downto 0) := (others => '0');
    signal s_axi_awvalid       : std_logic := '0';
    signal s_axi_awready       : std_logic;
    signal s_axi_wdata         : std_logic_vector(31 downto 0) := (others => '0');
    signal s_axi_wstrb         : std_logic_vector(3 downto 0) := (others => '1');
    signal s_axi_wvalid        : std_logic := '0';
    signal s_axi_wready        : std_logic;
    signal s_axi_bresp         : std_logic_vector(1 downto 0);
    signal s_axi_bvalid        : std_logic;
    signal s_axi_bready        : std_logic := '1';
    signal s_axi_araddr        : std_logic_vector(4 downto 0) := (others => '0');
    signal s_axi_arprot        : std_logic_vector(2 downto 0) := (others => '0');
    signal s_axi_arvalid       : std_logic := '0';
    signal s_axi_arready       : std_logic;
    signal s_axi_rdata         : std_logic_vector(31 downto 0);
    signal s_axi_rresp         : std_logic_vector(1 downto 0);
    signal s_axi_rvalid        : std_logic;
    signal s_axi_rready        : std_logic := '1';

    function piano_like_sample(
        sample_idx : natural;
        freq_hz    : real;
        amplitude  : real
    ) return integer is
        variable phase      : real;
        variable envelope   : real;
        variable sample_val : real;
    begin
        phase := 2.0 * MATH_PI * freq_hz * real(sample_idx) / SAMPLE_RATE_HZ;

        if sample_idx < 48 then
            envelope := real(sample_idx + 1) / 48.0;
        else
            envelope := 1.0;
        end if;

        sample_val :=
            amplitude * envelope *
            (0.92 * sin(phase) +
             0.05 * sin(2.0 * phase + 0.11) +
             0.03 * sin(3.0 * phase + 0.19));

        if sample_val >= 0.0 then
            return integer(sample_val + 0.5);
        else
            return integer(sample_val - 0.5);
        end if;
    end function;
begin
    clock_proc : process
    begin
        while sim_done = '0' loop
            aclk <= '0';
            wait for CLK_PERIOD / 2;
            aclk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        aclk <= '0';
        wait;
    end process;

    dut : entity work.piano_note_detect
        generic map (
            FRAME_SIZE    => FRAME_SIZE_G,
            HOP_SIZE      => HOP_SIZE_G,
            STABLE_FRAMES => STABLE_FRAMES_G
        )
        port map (
            aclk                => aclk,
            aresetn             => aresetn,
            s_axis_audio_tdata  => s_axis_audio_tdata,
            s_axis_audio_tvalid => s_axis_audio_tvalid,
            s_axis_audio_tready => s_axis_audio_tready,
            irq                 => irq,
            s_axi_awaddr        => s_axi_awaddr,
            s_axi_awprot        => s_axi_awprot,
            s_axi_awvalid       => s_axi_awvalid,
            s_axi_awready       => s_axi_awready,
            s_axi_wdata         => s_axi_wdata,
            s_axi_wstrb         => s_axi_wstrb,
            s_axi_wvalid        => s_axi_wvalid,
            s_axi_wready        => s_axi_wready,
            s_axi_bresp         => s_axi_bresp,
            s_axi_bvalid        => s_axi_bvalid,
            s_axi_bready        => s_axi_bready,
            s_axi_araddr        => s_axi_araddr,
            s_axi_arprot        => s_axi_arprot,
            s_axi_arvalid       => s_axi_arvalid,
            s_axi_arready       => s_axi_arready,
            s_axi_rdata         => s_axi_rdata,
            s_axi_rresp         => s_axi_rresp,
            s_axi_rvalid        => s_axi_rvalid,
            s_axi_rready        => s_axi_rready
        );

    stim_proc : process
        procedure write_reg(
            constant reg_addr : natural;
            constant reg_data : std_logic_vector(31 downto 0)
        ) is
        begin
            s_axi_awaddr  <= std_logic_vector(to_unsigned(reg_addr, s_axi_awaddr'length));
            s_axi_awvalid <= '1';
            s_axi_wdata   <= reg_data;
            s_axi_wvalid  <= '1';

            loop
                wait until rising_edge(aclk);
                exit when s_axi_awready = '1' and s_axi_wready = '1';
            end loop;

            s_axi_awvalid <= '0';
            s_axi_wvalid  <= '0';
            s_axi_awaddr  <= (others => '0');
            s_axi_wdata   <= (others => '0');

            loop
                wait until rising_edge(aclk);
                exit when s_axi_bvalid = '1';
            end loop;
        end procedure;

        procedure read_reg(
            constant reg_addr : natural;
            variable reg_data : out std_logic_vector(31 downto 0)
        ) is
        begin
            s_axi_araddr  <= std_logic_vector(to_unsigned(reg_addr, s_axi_araddr'length));
            s_axi_arvalid <= '1';

            loop
                wait until rising_edge(aclk);
                exit when s_axi_arready = '1';
            end loop;

            s_axi_arvalid <= '0';
            s_axi_araddr  <= (others => '0');

            loop
                wait until rising_edge(aclk);
                exit when s_axi_rvalid = '1';
            end loop;

            reg_data := s_axi_rdata;
        end procedure;

        procedure wait_clocks(constant count : natural) is
        begin
            for i in 1 to count loop
                wait until rising_edge(aclk);
            end loop;
        end procedure;

        procedure clear_event_latch is
        begin
            write_reg(REG_CONTROL, CONTROL_CLEAR_EVENT);
            write_reg(REG_CONTROL, (others => '0'));
        end procedure;

        procedure send_sample(constant sample_value : integer) is
        begin
            s_axis_audio_tdata  <= std_logic_vector(to_signed(sample_value, 32));
            s_axis_audio_tvalid <= '1';

            loop
                wait until rising_edge(aclk);
                wait for 0 ns;
                exit when s_axis_audio_tready = '1';
            end loop;

            s_axis_audio_tvalid <= '0';
            s_axis_audio_tdata  <= (others => '0');
        end procedure;

        procedure play_note(
            constant freq_hz      : real;
            constant amplitude    : real;
            constant sample_count : natural
        ) is
        begin
            for sample_idx in 0 to sample_count - 1 loop
                send_sample(piano_like_sample(sample_idx, freq_hz, amplitude));
            end loop;
        end procedure;

        procedure play_silence(constant sample_count : natural) is
        begin
            for sample_idx in 0 to sample_count - 1 loop
                send_sample(0);
            end loop;
        end procedure;

        procedure wait_for_event_count(
            constant expected_count : natural;
            constant max_cycles     : natural
        ) is
            constant POLL_PERIOD : natural := 64;
            variable event_data  : std_logic_vector(31 downto 0);
            variable status_data : std_logic_vector(31 downto 0);
            variable key_data    : std_logic_vector(31 downto 0);
            variable midi_data   : std_logic_vector(31 downto 0);
        begin
            read_reg(REG_EVENT_COUNTER, event_data);
            if to_integer(unsigned(event_data)) >= expected_count then
                return;
            end if;

            for cycle_idx in 1 to integer(max_cycles / POLL_PERIOD) loop
                wait_clocks(POLL_PERIOD);
                read_reg(REG_EVENT_COUNTER, event_data);
                if to_integer(unsigned(event_data)) >= expected_count then
                    return;
                end if;
            end loop;

            read_reg(REG_STATUS, status_data);
            read_reg(REG_PIANO_KEY, key_data);
            read_reg(REG_MIDI, midi_data);

            assert false
                report "Timed out waiting for detector event count; current_count=" &
                       integer'image(to_integer(unsigned(event_data))) &
                       " note_valid=" & std_logic'image(status_data(0)) &
                       " piano_key=" & integer'image(to_integer(unsigned(key_data(7 downto 0)))) &
                       " midi=" & integer'image(to_integer(unsigned(midi_data(7 downto 0))))
                severity failure;
        end procedure;

        procedure check_note_event(
            constant expected_key        : natural;
            constant expected_event_count: natural
        ) is
            constant expected_idx : natural := expected_key - 1;
            variable status_data  : std_logic_vector(31 downto 0);
            variable key_data     : std_logic_vector(31 downto 0);
            variable midi_data    : std_logic_vector(31 downto 0);
            variable freq_data    : std_logic_vector(31 downto 0);
            variable level_data   : std_logic_vector(31 downto 0);
            variable cents_data   : std_logic_vector(31 downto 0);
            variable event_data   : std_logic_vector(31 downto 0);
        begin
            read_reg(REG_STATUS, status_data);
            read_reg(REG_PIANO_KEY, key_data);
            read_reg(REG_MIDI, midi_data);
            read_reg(REG_FREQUENCY, freq_data);
            read_reg(REG_LEVEL, level_data);
            read_reg(REG_CENTS, cents_data);
            read_reg(REG_EVENT_COUNTER, event_data);

            report "Decoded key=" & integer'image(to_integer(unsigned(key_data(7 downto 0)))) &
                   " midi=" & integer'image(to_integer(unsigned(midi_data(7 downto 0)))) &
                   " event_count=" & integer'image(to_integer(unsigned(event_data))) &
                   " freq_q16_16=" & integer'image(to_integer(unsigned(freq_data))) &
                   " level=" & integer'image(to_integer(unsigned(level_data(15 downto 0))))
                severity note;

            assert status_data(0) = '1'
                report "Detector did not assert note_valid"
                severity failure;
            assert status_data(1) = '1'
                report "Detector did not latch new_event"
                severity failure;

            assert to_integer(unsigned(key_data(7 downto 0))) = expected_key
                report "Unexpected piano key"
                severity failure;

            assert to_integer(unsigned(midi_data(7 downto 0))) = to_integer(NOTE_MIDI(expected_idx))
                report "Unexpected MIDI note"
                severity failure;

            assert unsigned(freq_data) = NOTE_FREQ_Q16_16(expected_idx)
                report "Unexpected decoded frequency register"
                severity failure;

            assert unsigned(level_data(15 downto 0)) /= to_unsigned(0, 16)
                report "Signal level register stayed at zero"
                severity failure;

            assert signed(cents_data(15 downto 0)) = to_signed(0, 16)
                report "Cents register changed unexpectedly"
                severity failure;

            assert to_integer(unsigned(event_data)) >= expected_event_count
                report "Unexpected event counter after note event"
                severity failure;
        end procedure;

        procedure check_note_cleared(constant expected_event_count : natural) is
            variable status_data : std_logic_vector(31 downto 0);
            variable key_data    : std_logic_vector(31 downto 0);
            variable midi_data   : std_logic_vector(31 downto 0);
            variable freq_data   : std_logic_vector(31 downto 0);
            variable event_data  : std_logic_vector(31 downto 0);
        begin
            read_reg(REG_STATUS, status_data);
            read_reg(REG_PIANO_KEY, key_data);
            read_reg(REG_MIDI, midi_data);
            read_reg(REG_FREQUENCY, freq_data);
            read_reg(REG_EVENT_COUNTER, event_data);

            report "After silence key=" & integer'image(to_integer(unsigned(key_data(7 downto 0)))) &
                   " midi=" & integer'image(to_integer(unsigned(midi_data(7 downto 0)))) &
                   " event_count=" & integer'image(to_integer(unsigned(event_data)))
                severity note;

            assert status_data(0) = '0'
                report "Detector failed to clear note_valid after silence"
                severity failure;
            assert status_data(1) = '1'
                report "Detector did not latch note-off event"
                severity failure;

            assert unsigned(key_data(7 downto 0)) = to_unsigned(0, 8)
                report "Piano key register did not clear"
                severity failure;

            assert unsigned(midi_data(7 downto 0)) = to_unsigned(0, 8)
                report "MIDI register did not clear"
                severity failure;

            assert unsigned(freq_data) = to_unsigned(0, 32)
                report "Frequency register did not clear"
                severity failure;

            assert to_integer(unsigned(event_data)) >= expected_event_count
                report "Unexpected event counter after note-off event"
                severity failure;
        end procedure;
    begin
        wait_clocks(4);
        aresetn <= '1';
        wait_clocks(4);

        report "Detector released from reset" severity note;

        report "Driving A4 stimulus" severity note;
        play_note(440.0, 2.2e6, 1024);
        report "Waiting for A4 detection" severity note;
        wait_for_event_count(1, 4000000);
        check_note_event(A4_KEY, 1);
        clear_event_latch;

        report "Driving silence for note-off" severity note;
        play_silence(768);
        report "Waiting for note-off detection" severity note;
        wait_for_event_count(2, 4000000);
        check_note_cleared(2);
        clear_event_latch;

        report "Driving C5 stimulus" severity note;
        play_note(523.2511306, 2.0e6, 1024);
        report "Waiting for C5 detection" severity note;
        wait_for_event_count(3, 4000000);
        check_note_event(C5_KEY, 3);

        report "piano_note_detect_tb completed successfully" severity note;
        sim_done <= '1';
        wait;
    end process;
end architecture;

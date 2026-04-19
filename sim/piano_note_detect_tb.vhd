library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
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

    signal aclk                : std_logic := '0';
    signal aresetn             : std_logic := '0';
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

    alias note_valid_dbg is
        << signal .piano_note_detect_tb.dut.note_valid_reg : std_logic >>;
    alias new_event_dbg is
        << signal .piano_note_detect_tb.dut.new_event_reg : std_logic >>;
    alias piano_key_dbg is
        << signal .piano_note_detect_tb.dut.piano_key_reg : unsigned(7 downto 0) >>;
    alias midi_dbg is
        << signal .piano_note_detect_tb.dut.midi_reg : unsigned(7 downto 0) >>;
    alias freq_dbg is
        << signal .piano_note_detect_tb.dut.freq_reg : std_logic_vector(31 downto 0) >>;
    alias level_dbg is
        << signal .piano_note_detect_tb.dut.level_reg : std_logic_vector(31 downto 0) >>;
    alias cents_dbg is
        << signal .piano_note_detect_tb.dut.cents_reg : std_logic_vector(31 downto 0) >>;
    alias event_counter_dbg is
        << signal .piano_note_detect_tb.dut.event_counter_reg : unsigned(31 downto 0) >>;
    alias silent_sample_count_dbg is
        << signal .piano_note_detect_tb.dut.silent_sample_count : integer >>;

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
    aclk <= not aclk after CLK_PERIOD / 2;

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
        procedure wait_clocks(constant count : natural) is
        begin
            for i in 1 to count loop
                wait until rising_edge(aclk);
            end loop;
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
        begin
            if to_integer(event_counter_dbg) >= expected_count then
                return;
            end if;

            for cycle_idx in 1 to max_cycles loop
                wait until rising_edge(aclk);
                if to_integer(event_counter_dbg) >= expected_count then
                    return;
                end if;
            end loop;

            assert false
                report "Timed out waiting for detector event count; current_count=" &
                       integer'image(to_integer(event_counter_dbg)) &
                       " note_valid=" & std_logic'image(note_valid_dbg) &
                       " silent_samples=" & integer'image(silent_sample_count_dbg) &
                       " piano_key=" & integer'image(to_integer(piano_key_dbg)) &
                       " midi=" & integer'image(to_integer(midi_dbg))
                severity failure;
        end procedure;

        procedure check_note_event(
            constant expected_key        : natural;
            constant expected_event_count: natural
        ) is
            constant expected_idx : natural := expected_key - 1;
        begin
            report "Decoded key=" & integer'image(to_integer(piano_key_dbg)) &
                   " midi=" & integer'image(to_integer(midi_dbg)) &
                   " event_count=" & integer'image(to_integer(event_counter_dbg)) &
                   " freq_q16_16=" & integer'image(to_integer(unsigned(freq_dbg))) &
                   " level=" & integer'image(to_integer(unsigned(level_dbg(15 downto 0))))
                severity note;

            assert note_valid_dbg = '1'
                report "Detector did not assert note_valid"
                severity failure;
            assert new_event_dbg = '1'
                report "Detector did not latch new_event"
                severity failure;

            assert to_integer(piano_key_dbg) = expected_key
                report "Unexpected piano key"
                severity failure;

            assert to_integer(midi_dbg) = to_integer(NOTE_MIDI(expected_idx))
                report "Unexpected MIDI note"
                severity failure;

            assert unsigned(freq_dbg) = NOTE_FREQ_Q16_16(expected_idx)
                report "Unexpected decoded frequency register"
                severity failure;

            assert unsigned(level_dbg(15 downto 0)) /= to_unsigned(0, 16)
                report "Signal level register stayed at zero"
                severity failure;

            assert signed(cents_dbg(15 downto 0)) = to_signed(0, 16)
                report "Cents register changed unexpectedly"
                severity failure;

            assert to_integer(event_counter_dbg) >= expected_event_count
                report "Unexpected event counter after note event"
                severity failure;
        end procedure;

        procedure check_note_cleared(constant expected_event_count : natural) is
        begin
            report "After silence key=" & integer'image(to_integer(piano_key_dbg)) &
                   " midi=" & integer'image(to_integer(midi_dbg)) &
                   " event_count=" & integer'image(to_integer(event_counter_dbg))
                severity note;

            assert note_valid_dbg = '0'
                report "Detector failed to clear note_valid after silence"
                severity failure;
            assert new_event_dbg = '1'
                report "Detector did not latch note-off event"
                severity failure;

            assert piano_key_dbg = to_unsigned(0, 8)
                report "Piano key register did not clear"
                severity failure;

            assert midi_dbg = to_unsigned(0, 8)
                report "MIDI register did not clear"
                severity failure;

            assert unsigned(freq_dbg) = to_unsigned(0, 32)
                report "Frequency register did not clear"
                severity failure;

            assert to_integer(event_counter_dbg) >= expected_event_count
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

        report "Driving silence for note-off" severity note;
        play_silence(768);
        report "Waiting for note-off detection" severity note;
        wait_for_event_count(2, 4000000);
        check_note_cleared(2);

        report "Driving C5 stimulus" severity note;
        play_note(523.2511306, 2.0e6, 1024);
        report "Waiting for C5 detection" severity note;
        wait_for_event_count(3, 4000000);
        check_note_event(C5_KEY, 3);

        report "piano_note_detect_tb completed successfully" severity note;
        finish;
    end process;
end architecture;

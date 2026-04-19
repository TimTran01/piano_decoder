library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.piano_note_tables_pkg.all;

entity piano_note_detect is
    generic (
        C_S_AXI_DATA_WIDTH : integer := 32;
        C_S_AXI_ADDR_WIDTH : integer := 5;
        FRAME_SIZE         : integer := 2048;
        HOP_SIZE           : integer := 1024;
        STABLE_FRAMES      : integer := 2
    );
    port (
        aclk               : in  std_logic;
        aresetn            : in  std_logic;
        s_axis_audio_tdata : in  std_logic_vector(31 downto 0);
        s_axis_audio_tvalid: in  std_logic;
        s_axis_audio_tready: out std_logic;
        irq                : out std_logic;
        s_axi_awaddr       : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_awprot       : in  std_logic_vector(2 downto 0);
        s_axi_awvalid      : in  std_logic;
        s_axi_awready      : out std_logic;
        s_axi_wdata        : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_wstrb        : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        s_axi_wvalid       : in  std_logic;
        s_axi_wready       : out std_logic;
        s_axi_bresp        : out std_logic_vector(1 downto 0);
        s_axi_bvalid       : out std_logic;
        s_axi_bready       : in  std_logic;
        s_axi_araddr       : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        s_axi_arprot       : in  std_logic_vector(2 downto 0);
        s_axi_arvalid      : in  std_logic;
        s_axi_arready      : out std_logic;
        s_axi_rdata        : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        s_axi_rresp        : out std_logic_vector(1 downto 0);
        s_axi_rvalid       : out std_logic;
        s_axi_rready       : in  std_logic
    );
end entity;

architecture rtl of piano_note_detect is
    attribute X_INTERFACE_INFO : string;
    attribute X_INTERFACE_PARAMETER : string;
    attribute X_INTERFACE_INFO of aclk : signal is "xilinx.com:signal:clock:1.0 aclk CLK";
    attribute X_INTERFACE_PARAMETER of aclk : signal is "FREQ_HZ 100000000, ASSOCIATED_BUSIF S_AXIS_AUDIO:S_AXI, ASSOCIATED_RESET aresetn";
    attribute X_INTERFACE_INFO of aresetn : signal is "xilinx.com:signal:reset:1.0 aresetn RST";
    attribute X_INTERFACE_PARAMETER of aresetn : signal is "POLARITY ACTIVE_LOW";
    attribute X_INTERFACE_INFO of s_axis_audio_tdata : signal is "xilinx.com:interface:axis:1.0 S_AXIS_AUDIO TDATA";
    attribute X_INTERFACE_INFO of s_axis_audio_tvalid : signal is "xilinx.com:interface:axis:1.0 S_AXIS_AUDIO TVALID";
    attribute X_INTERFACE_INFO of s_axis_audio_tready : signal is "xilinx.com:interface:axis:1.0 S_AXIS_AUDIO TREADY";
    attribute X_INTERFACE_INFO of irq : signal is "xilinx.com:signal:interrupt:1.0 irq INTERRUPT";
    attribute X_INTERFACE_PARAMETER of irq : signal is "SENSITIVITY LEVEL_HIGH";
    attribute X_INTERFACE_INFO of s_axi_awaddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI AWADDR";
    attribute X_INTERFACE_PARAMETER of s_axi_awaddr : signal is "PROTOCOL AXI4LITE, DATA_WIDTH 32, ADDR_WIDTH 5, FREQ_HZ 100000000, ID_WIDTH 0, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BRESP 1, HAS_RRESP 1, HAS_WSTRB 1";
    attribute X_INTERFACE_INFO of s_axi_awprot : signal is "xilinx.com:interface:aximm:1.0 S_AXI AWPROT";
    attribute X_INTERFACE_INFO of s_axi_awvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI AWVALID";
    attribute X_INTERFACE_INFO of s_axi_awready : signal is "xilinx.com:interface:aximm:1.0 S_AXI AWREADY";
    attribute X_INTERFACE_INFO of s_axi_wdata : signal is "xilinx.com:interface:aximm:1.0 S_AXI WDATA";
    attribute X_INTERFACE_INFO of s_axi_wstrb : signal is "xilinx.com:interface:aximm:1.0 S_AXI WSTRB";
    attribute X_INTERFACE_INFO of s_axi_wvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI WVALID";
    attribute X_INTERFACE_INFO of s_axi_wready : signal is "xilinx.com:interface:aximm:1.0 S_AXI WREADY";
    attribute X_INTERFACE_INFO of s_axi_bresp : signal is "xilinx.com:interface:aximm:1.0 S_AXI BRESP";
    attribute X_INTERFACE_INFO of s_axi_bvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI BVALID";
    attribute X_INTERFACE_INFO of s_axi_bready : signal is "xilinx.com:interface:aximm:1.0 S_AXI BREADY";
    attribute X_INTERFACE_INFO of s_axi_araddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI ARADDR";
    attribute X_INTERFACE_INFO of s_axi_arprot : signal is "xilinx.com:interface:aximm:1.0 S_AXI ARPROT";
    attribute X_INTERFACE_INFO of s_axi_arvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI ARVALID";
    attribute X_INTERFACE_INFO of s_axi_arready : signal is "xilinx.com:interface:aximm:1.0 S_AXI ARREADY";
    attribute X_INTERFACE_INFO of s_axi_rdata : signal is "xilinx.com:interface:aximm:1.0 S_AXI RDATA";
    attribute X_INTERFACE_INFO of s_axi_rresp : signal is "xilinx.com:interface:aximm:1.0 S_AXI RRESP";
    attribute X_INTERFACE_INFO of s_axi_rvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI RVALID";
    attribute X_INTERFACE_INFO of s_axi_rready : signal is "xilinx.com:interface:aximm:1.0 S_AXI RREADY";

    constant ADDR_LSB      : integer := 2;
    constant THRESHOLD_ABS : signed(31 downto 0) := to_signed(4000, 32);
    constant HP_FEEDBACK_Q8_8 : signed(31 downto 0) := to_signed(252, 32);
    constant INPUT_SILENCE_ABS : unsigned(31 downto 0) := to_unsigned(256, 32);
    constant AXI_RESP_OKAY : std_logic_vector(1 downto 0) := "00";
    constant AXI_RESP_SLVERR : std_logic_vector(1 downto 0) := "10";
    constant REG_CONTROL_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(16#00#, C_S_AXI_ADDR_WIDTH));
    constant REG_STATUS_ADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(16#04#, C_S_AXI_ADDR_WIDTH));
    constant REG_KEY_ADDR     : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(16#08#, C_S_AXI_ADDR_WIDTH));
    constant REG_MIDI_ADDR    : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(16#0C#, C_S_AXI_ADDR_WIDTH));
    constant REG_FREQ_ADDR    : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(16#10#, C_S_AXI_ADDR_WIDTH));
    constant REG_LEVEL_ADDR   : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(16#14#, C_S_AXI_ADDR_WIDTH));
    constant REG_CENTS_ADDR   : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := std_logic_vector(to_unsigned(16#18#, C_S_AXI_ADDR_WIDTH));

    type ana_state_t is (
        ANA_IDLE,
        ANA_RUN_FETCH,
        ANA_RUN_ABS,
        ANA_RUN_MUL_INIT,
        ANA_RUN_MUL_STEP,
        ANA_RUN_MUL_SIGN,
        ANA_RUN_ACCUM,
        ANA_EVAL_CAPTURE,
        ANA_EVAL_MUL_INIT,
        ANA_EVAL_MUL_STEP,
        ANA_EVAL_MUL_STORE,
        ANA_EVAL_COEFF_INIT,
        ANA_EVAL_COEFF_STEP,
        ANA_EVAL_COEFF_SIGN,
        ANA_EVAL_ACCUM,
        ANA_EVAL_SATURATE,
        ANA_EVAL_UPDATE,
        ANA_FINALIZE
    );
    type sample_ram_t is array (0 to FRAME_SIZE-1) of signed(31 downto 0);

    function signed_abs32(x : signed(31 downto 0)) return unsigned is
    begin
        if x(x'high) = '1' then
            return unsigned(-x);
        else
            return unsigned(x);
        end if;
    end function;

    function goertzel_next(
        sample_value : signed(31 downto 0);
        coeff        : signed(31 downto 0);
        q1_value     : signed(47 downto 0);
        q2_value     : signed(47 downto 0)
    ) return signed is
        variable mult_term : signed(79 downto 0);
        variable accum     : signed(79 downto 0);
    begin
        mult_term := coeff * q1_value;
        accum := resize(sample_value, 80) + shift_right(mult_term, 30) - resize(q2_value, 80);
        return resize(accum, 48);
    end function;

    function goertzel_power(
        coeff    : signed(31 downto 0);
        q1_value : signed(47 downto 0);
        q2_value : signed(47 downto 0)
    ) return unsigned is
        variable q1_sq      : signed(95 downto 0);
        variable q2_sq      : signed(95 downto 0);
        variable q1q2       : signed(95 downto 0);
        variable coeff_term : signed(127 downto 0);
        variable power_val  : signed(127 downto 0);
    begin
        q1_sq := q1_value * q1_value;
        q2_sq := q2_value * q2_value;
        q1q2 := q1_value * q2_value;
        coeff_term := coeff * q1q2;
        power_val := resize(q1_sq, 128) + resize(q2_sq, 128) - shift_right(coeff_term, 30);
        if power_val(power_val'high) = '1' then
            return to_unsigned(0, 128);
        else
            return unsigned(power_val);
        end if;
    end function;

    signal awready_r          : std_logic := '0';
    signal wready_r           : std_logic := '0';
    signal bvalid_r           : std_logic := '0';
    signal arready_r          : std_logic := '0';
    signal rvalid_r           : std_logic := '0';
    signal bresp_r            : std_logic_vector(1 downto 0) := (others => '0');
    signal rresp_r            : std_logic_vector(1 downto 0) := (others => '0');
    signal rdata_r            : std_logic_vector(31 downto 0) := (others => '0');
    signal control_reg        : std_logic_vector(31 downto 0) := (others => '0');
    signal status_reg         : std_logic_vector(31 downto 0) := (others => '0');
    signal freq_reg           : std_logic_vector(31 downto 0) := (others => '0');
    signal level_reg          : std_logic_vector(31 downto 0) := (others => '0');
    signal cents_reg          : std_logic_vector(31 downto 0) := (others => '0');
    signal event_counter_reg  : unsigned(31 downto 0) := (others => '0');
    signal piano_key_reg      : unsigned(7 downto 0) := (others => '0');
    signal midi_reg           : unsigned(7 downto 0) := (others => '0');
    signal new_event_reg      : std_logic := '0';
    signal irq_reg            : std_logic := '0';
    signal overflow_reg       : std_logic := '0';
    signal signal_present_reg : std_logic := '0';
    signal note_valid_reg     : std_logic := '0';

    signal sample_ram         : sample_ram_t := (others => (others => '0'));
    signal wr_ptr             : integer range 0 to FRAME_SIZE-1 := 0;
    signal warmup_count       : integer range 0 to FRAME_SIZE := 0;
    signal hop_count          : integer range 0 to HOP_SIZE := 0;
    signal analysis_pending   : std_logic := '0';
    signal dc_est             : signed(31 downto 0) := (others => '0');
    signal hp_prev            : signed(31 downto 0) := (others => '0');
    signal ana_state          : ana_state_t := ANA_IDLE;
    signal note_idx           : integer range 0 to NOTE_COUNT-1;
    signal sample_idx         : integer range 0 to FRAME_SIZE-1 := 0;
    signal window_start       : integer range 0 to FRAME_SIZE-1 := 0;
    signal analysis_sample_reg: signed(31 downto 0) := (others => '0');
    signal goertzel_mult_reg  : signed(49 downto 0) := (others => '0');
    signal goertzel_mult_accum_reg       : unsigned(79 downto 0) := (others => '0');
    signal goertzel_mult_multiplicand_reg: unsigned(79 downto 0) := (others => '0');
    signal goertzel_mult_multiplier_reg  : unsigned(31 downto 0) := (others => '0');
    signal goertzel_mult_sign_reg        : std_logic := '0';
    signal goertzel_mult_count           : integer range 0 to 31 := 0;
    signal q1                 : signed(47 downto 0) := (others => '0');
    signal q2                 : signed(47 downto 0) := (others => '0');
    signal q1_eval_reg        : signed(47 downto 0) := (others => '0');
    signal q2_eval_reg        : signed(47 downto 0) := (others => '0');
    signal note_coeff_reg     : signed(31 downto 0) := (others => '0');
    signal eval_mult_accum_reg       : unsigned(95 downto 0) := (others => '0');
    signal eval_mult_multiplicand_reg: unsigned(95 downto 0) := (others => '0');
    signal eval_mult_multiplier_reg  : unsigned(47 downto 0) := (others => '0');
    signal eval_mult_sign_reg        : std_logic := '0';
    signal eval_mult_count           : integer range 0 to 47 := 0;
    signal eval_mult_select          : integer range 0 to 2 := 0;
    signal power_q1_sq_reg    : signed(95 downto 0) := (others => '0');
    signal power_q2_sq_reg    : signed(95 downto 0) := (others => '0');
    signal power_q1q2_reg     : signed(95 downto 0) := (others => '0');
    signal power_sum_reg      : signed(127 downto 0) := (others => '0');
    signal power_coeff_reg    : signed(127 downto 0) := (others => '0');
    signal power_accum_reg    : signed(127 downto 0) := (others => '0');
    signal coeff_mult_accum_reg       : unsigned(127 downto 0) := (others => '0');
    signal coeff_mult_multiplicand_reg: unsigned(127 downto 0) := (others => '0');
    signal coeff_mult_multiplier_reg  : unsigned(31 downto 0) := (others => '0');
    signal coeff_mult_sign_reg        : std_logic := '0';
    signal coeff_mult_count           : integer range 0 to 31 := 0;
    signal eval_power_reg     : unsigned(127 downto 0) := (others => '0');
    signal best_power         : unsigned(127 downto 0) := (others => '0');
    signal best_note_idx      : integer range 0 to NOTE_COUNT-1;
    signal frame_abs_sum      : unsigned(63 downto 0) := (others => '0');
    signal stable_count       : integer range 0 to 255 := 0;
    signal silent_sample_count : integer range 0 to FRAME_SIZE := 0;
    signal pending_key        : unsigned(7 downto 0) := (others => '0');
    signal pending_valid      : std_logic := '0';
    signal audio_accept_ready : std_logic := '0';
begin
    audio_accept_ready <= '1' when (overflow_reg = '0' and analysis_pending = '0' and ana_state = ANA_IDLE) else '0';
    s_axis_audio_tready <= audio_accept_ready;
    irq <= irq_reg;

    s_axi_awready <= awready_r;
    s_axi_wready  <= wready_r;
    s_axi_bresp   <= bresp_r;
    s_axi_bvalid  <= bvalid_r;
    s_axi_arready <= arready_r;
    s_axi_rdata   <= rdata_r;
    s_axi_rresp   <= rresp_r;
    s_axi_rvalid  <= rvalid_r;

    axi_proc : process(aclk)
        variable write_data_masked : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                awready_r <= '0';
                wready_r <= '0';
                bvalid_r <= '0';
                arready_r <= '0';
                rvalid_r <= '0';
                bresp_r <= (others => '0');
                rresp_r <= (others => '0');
                rdata_r <= (others => '0');
                control_reg <= (others => '0');
            else
                awready_r <= '0';
                wready_r <= '0';
                arready_r <= '0';
                write_data_masked := control_reg;

                if s_axi_awvalid = '1' and s_axi_wvalid = '1' and bvalid_r = '0' then
                    awready_r <= '1';
                    wready_r <= '1';
                    bvalid_r <= '1';
                    bresp_r <= AXI_RESP_OKAY;
                    for byte_idx in 0 to (C_S_AXI_DATA_WIDTH/8)-1 loop
                        if s_axi_wstrb(byte_idx) = '1' then
                            write_data_masked((byte_idx * 8) + 7 downto byte_idx * 8) :=
                                s_axi_wdata((byte_idx * 8) + 7 downto byte_idx * 8);
                        end if;
                    end loop;
                    if s_axi_awprot = "000" then
                        if s_axi_awaddr = REG_CONTROL_ADDR then
                            control_reg <= write_data_masked;
                        end if;
                    else
                        bresp_r <= AXI_RESP_SLVERR;
                    end if;
                end if;

                if bvalid_r = '1' and s_axi_bready = '1' then
                    bvalid_r <= '0';
                end if;

                if s_axi_arvalid = '1' and rvalid_r = '0' then
                    arready_r <= '1';
                    rvalid_r <= '1';
                    rresp_r <= AXI_RESP_OKAY;
                    if s_axi_arprot = "000" then
                        case s_axi_araddr is
                            when REG_CONTROL_ADDR => rdata_r <= control_reg;
                            when REG_STATUS_ADDR  => rdata_r <= status_reg;
                            when REG_KEY_ADDR     => rdata_r <= (31 downto 8 => '0') & std_logic_vector(piano_key_reg);
                            when REG_MIDI_ADDR    => rdata_r <= (31 downto 8 => '0') & std_logic_vector(midi_reg);
                            when REG_FREQ_ADDR    => rdata_r <= freq_reg;
                            when REG_LEVEL_ADDR   => rdata_r <= level_reg;
                            when REG_CENTS_ADDR   => rdata_r <= cents_reg;
                            when others           => rdata_r <= std_logic_vector(event_counter_reg);
                        end case;
                    else
                        rresp_r <= AXI_RESP_SLVERR;
                        rdata_r <= (others => '0');
                    end if;
                end if;

                if rvalid_r = '1' and s_axi_rready = '1' then
                    rvalid_r <= '0';
                end if;
            end if;
        end if;
    end process;

    detector_proc : process(aclk)
        variable input_sample        : signed(31 downto 0);
        variable sample_accept       : boolean;
        variable analysis_sample     : signed(31 downto 0);
        variable read_index          : integer range 0 to FRAME_SIZE-1;
        variable next_q0             : signed(79 downto 0);
        variable current_power       : unsigned(127 downto 0);
        variable signal_detected_now : std_logic;
        variable level_q1_15         : unsigned(15 downto 0);
        variable candidate_key       : unsigned(7 downto 0);
        variable candidate_midi      : unsigned(7 downto 0);
        variable candidate_freq      : unsigned(31 downto 0);
        variable abs_sample          : unsigned(31 downto 0);
        variable hp_temp             : signed(31 downto 0);
        variable dc_temp             : signed(31 downto 0);
        variable power_accum         : signed(127 downto 0);
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                wr_ptr <= 0;
                warmup_count <= 0;
                hop_count <= 0;
                analysis_pending <= '0';
                dc_est <= (others => '0');
                hp_prev <= (others => '0');
                ana_state <= ANA_IDLE;
                note_idx <= 0;
                sample_idx <= 0;
                window_start <= 0;
                analysis_sample_reg <= (others => '0');
                goertzel_mult_reg <= (others => '0');
                goertzel_mult_accum_reg <= (others => '0');
                goertzel_mult_multiplicand_reg <= (others => '0');
                goertzel_mult_multiplier_reg <= (others => '0');
                goertzel_mult_sign_reg <= '0';
                goertzel_mult_count <= 0;
                q1 <= (others => '0');
                q2 <= (others => '0');
                q1_eval_reg <= (others => '0');
                q2_eval_reg <= (others => '0');
                note_coeff_reg <= (others => '0');
                eval_mult_accum_reg <= (others => '0');
                eval_mult_multiplicand_reg <= (others => '0');
                eval_mult_multiplier_reg <= (others => '0');
                eval_mult_sign_reg <= '0';
                eval_mult_count <= 0;
                eval_mult_select <= 0;
                power_q1_sq_reg <= (others => '0');
                power_q2_sq_reg <= (others => '0');
                power_q1q2_reg <= (others => '0');
                power_sum_reg <= (others => '0');
                power_coeff_reg <= (others => '0');
                power_accum_reg <= (others => '0');
                coeff_mult_accum_reg <= (others => '0');
                coeff_mult_multiplicand_reg <= (others => '0');
                coeff_mult_multiplier_reg <= (others => '0');
                coeff_mult_sign_reg <= '0';
                coeff_mult_count <= 0;
                eval_power_reg <= (others => '0');
                best_power <= (others => '0');
                best_note_idx <= 0;
                frame_abs_sum <= (others => '0');
                stable_count <= 0;
                silent_sample_count <= 0;
                pending_key <= (others => '0');
                pending_valid <= '0';
                piano_key_reg <= (others => '0');
                midi_reg <= (others => '0');
                freq_reg <= (others => '0');
                level_reg <= (others => '0');
                cents_reg <= (others => '0');
                event_counter_reg <= (others => '0');
                new_event_reg <= '0';
                irq_reg <= '0';
                overflow_reg <= '0';
                signal_present_reg <= '0';
                note_valid_reg <= '0';
                status_reg <= (others => '0');
            else
                if control_reg(0) = '1' then
                    new_event_reg <= '0';
                    irq_reg <= '0';
                end if;

                input_sample := signed(s_axis_audio_tdata);
                sample_accept := (s_axis_audio_tvalid = '1') and (audio_accept_ready = '1');

                if sample_accept then
                    if signed_abs32(input_sample) <= INPUT_SILENCE_ABS then
                        if silent_sample_count < FRAME_SIZE then
                            silent_sample_count <= silent_sample_count + 1;
                        end if;
                    else
                        silent_sample_count <= 0;
                    end if;

                    dc_temp := dc_est + shift_right(input_sample - dc_est, 8);
                    hp_temp := input_sample - dc_est +
                               resize(shift_right(hp_prev * HP_FEEDBACK_Q8_8, 8), hp_temp'length);
                    dc_est <= dc_temp;
                    hp_prev <= hp_temp;
                    sample_ram(wr_ptr) <= hp_temp;

                    if wr_ptr = FRAME_SIZE - 1 then
                        wr_ptr <= 0;
                    else
                        wr_ptr <= wr_ptr + 1;
                    end if;

                    if warmup_count < FRAME_SIZE then
                        warmup_count <= warmup_count + 1;
                    end if;

                    if warmup_count >= FRAME_SIZE - 1 then
                        if hop_count = HOP_SIZE - 1 then
                            hop_count <= 0;
                            analysis_pending <= '1';
                        else
                            hop_count <= hop_count + 1;
                        end if;
                    end if;
                end if;

                if note_valid_reg = '1' and sample_accept and signed_abs32(input_sample) <= INPUT_SILENCE_ABS and
                   silent_sample_count = HOP_SIZE - 1 then
                    pending_valid <= '0';
                    stable_count <= 0;
                    silent_sample_count <= HOP_SIZE;
                    note_valid_reg <= '0';
                    piano_key_reg <= (others => '0');
                    midi_reg <= (others => '0');
                    freq_reg <= (others => '0');
                    cents_reg <= (others => '0');
                    new_event_reg <= '1';
                    irq_reg <= control_reg(1);
                    event_counter_reg <= event_counter_reg + 1;
                end if;

                case ana_state is
                    when ANA_IDLE =>
                        if analysis_pending = '1' then
                            analysis_pending <= '0';
                            ana_state <= ANA_RUN_FETCH;
                            window_start <= wr_ptr;
                            note_idx <= 0;
                            sample_idx <= 0;
                            analysis_sample_reg <= (others => '0');
                            goertzel_mult_reg <= (others => '0');
                            goertzel_mult_accum_reg <= (others => '0');
                            goertzel_mult_multiplicand_reg <= (others => '0');
                            goertzel_mult_multiplier_reg <= (others => '0');
                            goertzel_mult_sign_reg <= '0';
                            goertzel_mult_count <= 0;
                            q1 <= (others => '0');
                            q2 <= (others => '0');
                            q1_eval_reg <= (others => '0');
                            q2_eval_reg <= (others => '0');
                            note_coeff_reg <= NOTE_COEFF_Q2_30(0);
                            eval_mult_accum_reg <= (others => '0');
                            eval_mult_multiplicand_reg <= (others => '0');
                            eval_mult_multiplier_reg <= (others => '0');
                            eval_mult_sign_reg <= '0';
                            eval_mult_count <= 0;
                            eval_mult_select <= 0;
                            power_q1_sq_reg <= (others => '0');
                            power_q2_sq_reg <= (others => '0');
                            power_q1q2_reg <= (others => '0');
                            power_sum_reg <= (others => '0');
                            power_coeff_reg <= (others => '0');
                            power_accum_reg <= (others => '0');
                            coeff_mult_accum_reg <= (others => '0');
                            coeff_mult_multiplicand_reg <= (others => '0');
                            coeff_mult_multiplier_reg <= (others => '0');
                            coeff_mult_sign_reg <= '0';
                            coeff_mult_count <= 0;
                            eval_power_reg <= (others => '0');
                            best_power <= (others => '0');
                            best_note_idx <= 0;
                            frame_abs_sum <= (others => '0');
                        end if;

                    when ANA_RUN_FETCH =>
                        read_index := window_start + sample_idx;
                        if read_index >= FRAME_SIZE then
                            read_index := read_index - FRAME_SIZE;
                        end if;
                        analysis_sample := sample_ram(read_index);
                        analysis_sample_reg <= analysis_sample;
                        if note_idx = 0 then
                            ana_state <= ANA_RUN_ABS;
                        else
                            ana_state <= ANA_RUN_MUL_INIT;
                        end if;

                    when ANA_RUN_ABS =>
                        abs_sample := signed_abs32(analysis_sample_reg);
                        frame_abs_sum <= frame_abs_sum + resize(abs_sample, 64);
                        ana_state <= ANA_RUN_MUL_INIT;

                    when ANA_RUN_MUL_INIT =>
                        goertzel_mult_accum_reg <= (others => '0');
                        if q1(q1'high) = '1' then
                            goertzel_mult_multiplicand_reg <= unsigned(resize(-q1, 80));
                        else
                            goertzel_mult_multiplicand_reg <= unsigned(resize(q1, 80));
                        end if;
                        goertzel_mult_multiplier_reg <= signed_abs32(note_coeff_reg);
                        goertzel_mult_sign_reg <= q1(q1'high) xor note_coeff_reg(note_coeff_reg'high);
                        goertzel_mult_count <= 0;
                        ana_state <= ANA_RUN_MUL_STEP;

                    when ANA_RUN_MUL_STEP =>
                        if goertzel_mult_multiplier_reg(0) = '1' then
                            goertzel_mult_accum_reg <= goertzel_mult_accum_reg + goertzel_mult_multiplicand_reg;
                        end if;
                        goertzel_mult_multiplicand_reg <= shift_left(goertzel_mult_multiplicand_reg, 1);
                        goertzel_mult_multiplier_reg <= shift_right(goertzel_mult_multiplier_reg, 1);
                        if goertzel_mult_count = 31 then
                            ana_state <= ANA_RUN_MUL_SIGN;
                        else
                            goertzel_mult_count <= goertzel_mult_count + 1;
                        end if;

                    when ANA_RUN_MUL_SIGN =>
                        if goertzel_mult_sign_reg = '1' then
                            goertzel_mult_reg <= resize(shift_right(-signed(goertzel_mult_accum_reg), 30), goertzel_mult_reg'length);
                        else
                            goertzel_mult_reg <= resize(shift_right(signed(goertzel_mult_accum_reg), 30), goertzel_mult_reg'length);
                        end if;
                        ana_state <= ANA_RUN_ACCUM;

                    when ANA_RUN_ACCUM =>
                        next_q0 := resize(analysis_sample_reg, 80) + resize(goertzel_mult_reg, 80) - resize(q2, 80);
                        q2 <= q1;
                        q1 <= resize(next_q0, 48);
                        if sample_idx = FRAME_SIZE - 1 then
                            ana_state <= ANA_EVAL_CAPTURE;
                        else
                            sample_idx <= sample_idx + 1;
                            ana_state <= ANA_RUN_FETCH;
                        end if;

                    when ANA_EVAL_CAPTURE =>
                        q1_eval_reg <= q1;
                        q2_eval_reg <= q2;
                        ana_state <= ANA_EVAL_MUL_INIT;

                    when ANA_EVAL_MUL_INIT =>
                        eval_mult_accum_reg <= (others => '0');
                        if q1_eval_reg(q1_eval_reg'high) = '1' then
                            eval_mult_multiplicand_reg <= unsigned(resize(-q1_eval_reg, 96));
                            eval_mult_multiplier_reg <= unsigned(-q1_eval_reg);
                        else
                            eval_mult_multiplicand_reg <= unsigned(resize(q1_eval_reg, 96));
                            eval_mult_multiplier_reg <= unsigned(q1_eval_reg);
                        end if;
                        eval_mult_sign_reg <= '0';
                        eval_mult_count <= 0;
                        eval_mult_select <= 0;
                        ana_state <= ANA_EVAL_MUL_STEP;

                    when ANA_EVAL_MUL_STEP =>
                        if eval_mult_multiplier_reg(0) = '1' then
                            eval_mult_accum_reg <= eval_mult_accum_reg + eval_mult_multiplicand_reg;
                        end if;
                        eval_mult_multiplicand_reg <= shift_left(eval_mult_multiplicand_reg, 1);
                        eval_mult_multiplier_reg <= shift_right(eval_mult_multiplier_reg, 1);
                        if eval_mult_count = 47 then
                            ana_state <= ANA_EVAL_MUL_STORE;
                        else
                            eval_mult_count <= eval_mult_count + 1;
                        end if;

                    when ANA_EVAL_MUL_STORE =>
                        if eval_mult_select = 0 then
                            power_q1_sq_reg <= signed(eval_mult_accum_reg);
                            eval_mult_accum_reg <= (others => '0');
                            if q2_eval_reg(q2_eval_reg'high) = '1' then
                                eval_mult_multiplicand_reg <= unsigned(resize(-q2_eval_reg, 96));
                                eval_mult_multiplier_reg <= unsigned(-q2_eval_reg);
                            else
                                eval_mult_multiplicand_reg <= unsigned(resize(q2_eval_reg, 96));
                                eval_mult_multiplier_reg <= unsigned(q2_eval_reg);
                            end if;
                            eval_mult_sign_reg <= '0';
                            eval_mult_count <= 0;
                            eval_mult_select <= 1;
                            ana_state <= ANA_EVAL_MUL_STEP;
                        elsif eval_mult_select = 1 then
                            power_q2_sq_reg <= signed(eval_mult_accum_reg);
                            eval_mult_accum_reg <= (others => '0');
                            if q1_eval_reg(q1_eval_reg'high) = '1' then
                                eval_mult_multiplicand_reg <= unsigned(resize(-q1_eval_reg, 96));
                            else
                                eval_mult_multiplicand_reg <= unsigned(resize(q1_eval_reg, 96));
                            end if;
                            if q2_eval_reg(q2_eval_reg'high) = '1' then
                                eval_mult_multiplier_reg <= unsigned(-q2_eval_reg);
                            else
                                eval_mult_multiplier_reg <= unsigned(q2_eval_reg);
                            end if;
                            eval_mult_sign_reg <= q1_eval_reg(q1_eval_reg'high) xor q2_eval_reg(q2_eval_reg'high);
                            eval_mult_count <= 0;
                            eval_mult_select <= 2;
                            ana_state <= ANA_EVAL_MUL_STEP;
                        else
                            if eval_mult_sign_reg = '1' then
                                power_q1q2_reg <= -signed(eval_mult_accum_reg);
                            else
                                power_q1q2_reg <= signed(eval_mult_accum_reg);
                            end if;
                            ana_state <= ANA_EVAL_COEFF_INIT;
                        end if;

                    when ANA_EVAL_COEFF_INIT =>
                        power_sum_reg <= resize(power_q1_sq_reg, 128) + resize(power_q2_sq_reg, 128);
                        power_coeff_reg <= (others => '0');
                        power_accum_reg <= (others => '0');
                        coeff_mult_accum_reg <= (others => '0');
                        if power_q1q2_reg(power_q1q2_reg'high) = '1' then
                            coeff_mult_multiplicand_reg <= unsigned(resize(-power_q1q2_reg, 128));
                        else
                            coeff_mult_multiplicand_reg <= unsigned(resize(power_q1q2_reg, 128));
                        end if;
                        coeff_mult_multiplier_reg <= signed_abs32(note_coeff_reg);
                        coeff_mult_sign_reg <= power_q1q2_reg(power_q1q2_reg'high) xor note_coeff_reg(note_coeff_reg'high);
                        coeff_mult_count <= 0;
                        ana_state <= ANA_EVAL_COEFF_STEP;

                    when ANA_EVAL_COEFF_STEP =>
                        if coeff_mult_multiplier_reg(0) = '1' then
                            coeff_mult_accum_reg <= coeff_mult_accum_reg + coeff_mult_multiplicand_reg;
                        end if;
                        coeff_mult_multiplicand_reg <= shift_left(coeff_mult_multiplicand_reg, 1);
                        coeff_mult_multiplier_reg <= shift_right(coeff_mult_multiplier_reg, 1);
                        if coeff_mult_count = 31 then
                            ana_state <= ANA_EVAL_COEFF_SIGN;
                        else
                            coeff_mult_count <= coeff_mult_count + 1;
                        end if;

                    when ANA_EVAL_COEFF_SIGN =>
                        if coeff_mult_sign_reg = '1' then
                            power_coeff_reg <= -signed(coeff_mult_accum_reg);
                        else
                            power_coeff_reg <= signed(coeff_mult_accum_reg);
                        end if;
                        ana_state <= ANA_EVAL_ACCUM;

                    when ANA_EVAL_ACCUM =>
                        power_accum := power_sum_reg - shift_right(power_coeff_reg, 30);
                        power_accum_reg <= power_accum;
                        ana_state <= ANA_EVAL_SATURATE;

                    when ANA_EVAL_SATURATE =>
                        if power_accum_reg(power_accum_reg'high) = '1' then
                            eval_power_reg <= to_unsigned(0, 128);
                        else
                            eval_power_reg <= unsigned(power_accum_reg);
                        end if;
                        ana_state <= ANA_EVAL_UPDATE;

                    when ANA_EVAL_UPDATE =>
                        current_power := eval_power_reg;
                        if current_power > best_power then
                            best_power <= current_power;
                            best_note_idx <= note_idx;
                        end if;

                        if note_idx = NOTE_COUNT - 1 then
                            ana_state <= ANA_FINALIZE;
                        else
                            note_idx <= note_idx + 1;
                            sample_idx <= 0;
                            analysis_sample_reg <= (others => '0');
                            goertzel_mult_reg <= (others => '0');
                            goertzel_mult_accum_reg <= (others => '0');
                            goertzel_mult_multiplicand_reg <= (others => '0');
                            goertzel_mult_multiplier_reg <= (others => '0');
                            goertzel_mult_sign_reg <= '0';
                            goertzel_mult_count <= 0;
                            q1 <= (others => '0');
                            q2 <= (others => '0');
                            q1_eval_reg <= (others => '0');
                            q2_eval_reg <= (others => '0');
                            note_coeff_reg <= NOTE_COEFF_Q2_30(note_idx + 1);
                            eval_mult_accum_reg <= (others => '0');
                            eval_mult_multiplicand_reg <= (others => '0');
                            eval_mult_multiplier_reg <= (others => '0');
                            eval_mult_sign_reg <= '0';
                            eval_mult_count <= 0;
                            eval_mult_select <= 0;
                            power_q1_sq_reg <= (others => '0');
                            power_q2_sq_reg <= (others => '0');
                            power_q1q2_reg <= (others => '0');
                            power_sum_reg <= (others => '0');
                            power_coeff_reg <= (others => '0');
                            power_accum_reg <= (others => '0');
                            coeff_mult_accum_reg <= (others => '0');
                            coeff_mult_multiplicand_reg <= (others => '0');
                            coeff_mult_multiplier_reg <= (others => '0');
                            coeff_mult_sign_reg <= '0';
                            coeff_mult_count <= 0;
                            ana_state <= ANA_RUN_FETCH;
                        end if;

                    when ANA_FINALIZE =>
                        candidate_key := to_unsigned(best_note_idx + 1, 8);
                        candidate_midi := NOTE_MIDI(best_note_idx);
                        candidate_freq := NOTE_FREQ_Q16_16(best_note_idx);
                        signal_detected_now := '0';
                        if frame_abs_sum > 0 and shift_right(frame_abs_sum, 11) > resize(unsigned(THRESHOLD_ABS), 64) then
                            signal_detected_now := '1';
                        end if;
                        if silent_sample_count >= HOP_SIZE then
                            signal_detected_now := '0';
                        end if;

                        if frame_abs_sum(63 downto 16) /= 0 then
                            level_q1_15 := (others => '1');
                        else
                            level_q1_15 := frame_abs_sum(30 downto 15);
                        end if;

                        ana_state <= ANA_IDLE;
                        level_reg <= (31 downto 16 => '0') & std_logic_vector(level_q1_15);
                        signal_present_reg <= signal_detected_now;

                        if signal_detected_now = '0' then
                            pending_valid <= '0';
                            stable_count <= 0;
                            if note_valid_reg = '1' then
                                note_valid_reg <= '0';
                                piano_key_reg <= (others => '0');
                                midi_reg <= (others => '0');
                                freq_reg <= (others => '0');
                                cents_reg <= (others => '0');
                                new_event_reg <= '1';
                                irq_reg <= control_reg(1);
                                event_counter_reg <= event_counter_reg + 1;
                            end if;
                        else
                            if pending_valid = '1' and pending_key = candidate_key then
                                if stable_count < 255 then
                                    stable_count <= stable_count + 1;
                                end if;
                            else
                                pending_valid <= '1';
                                pending_key <= candidate_key;
                                stable_count <= 1;
                            end if;

                            if ((pending_valid = '1' and pending_key = candidate_key and stable_count + 1 >= STABLE_FRAMES) or
                               (pending_valid = '0' and STABLE_FRAMES = 1)) then
                                if note_valid_reg = '0' or piano_key_reg /= candidate_key then
                                    note_valid_reg <= '1';
                                    piano_key_reg <= candidate_key;
                                    midi_reg <= candidate_midi;
                                    freq_reg <= std_logic_vector(candidate_freq);
                                    cents_reg <= (others => '0');
                                    new_event_reg <= '1';
                                    irq_reg <= control_reg(1);
                                    event_counter_reg <= event_counter_reg + 1;
                                end if;
                            end if;
                        end if;
                end case;

                if ana_state /= ANA_IDLE then
                    status_reg <= (31 downto 5 => '0') & overflow_reg & signal_present_reg &
                                  '1' & new_event_reg & note_valid_reg;
                else
                    status_reg <= (31 downto 5 => '0') & overflow_reg & signal_present_reg &
                                  '0' & new_event_reg & note_valid_reg;
                end if;
            end if;
        end if;
    end process;
end architecture;

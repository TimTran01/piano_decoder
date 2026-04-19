library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity zybo_audio_in is
    generic (
        C_S_AXI_DATA_WIDTH : integer := 32;
        C_S_AXI_ADDR_WIDTH : integer := 4
    );
    port (
        aclk               : in  std_logic;
        aresetn            : in  std_logic;
        ac_bclk            : in  std_logic;
        ac_reclrc          : in  std_logic;
        ac_recdat          : in  std_logic;
        ac_pblrc           : in  std_logic;
        ac_pbdat           : out std_logic;
        ac_muten           : out std_logic;
        m_axis_audio_tdata : out std_logic_vector(31 downto 0);
        m_axis_audio_tvalid: out std_logic;
        m_axis_audio_tready: in  std_logic;
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

architecture rtl of zybo_audio_in is
    attribute X_INTERFACE_INFO : string;
    attribute X_INTERFACE_PARAMETER : string;
    attribute X_INTERFACE_INFO of aclk : signal is "xilinx.com:signal:clock:1.0 aclk CLK";
    attribute X_INTERFACE_PARAMETER of aclk : signal is "FREQ_HZ 100000000, ASSOCIATED_BUSIF M_AXIS_AUDIO:S_AXI, ASSOCIATED_RESET aresetn";
    attribute X_INTERFACE_INFO of aresetn : signal is "xilinx.com:signal:reset:1.0 aresetn RST";
    attribute X_INTERFACE_PARAMETER of aresetn : signal is "POLARITY ACTIVE_LOW";
    attribute X_INTERFACE_INFO of m_axis_audio_tdata : signal is "xilinx.com:interface:axis:1.0 M_AXIS_AUDIO TDATA";
    attribute X_INTERFACE_INFO of m_axis_audio_tvalid : signal is "xilinx.com:interface:axis:1.0 M_AXIS_AUDIO TVALID";
    attribute X_INTERFACE_INFO of m_axis_audio_tready : signal is "xilinx.com:interface:axis:1.0 M_AXIS_AUDIO TREADY";
    attribute X_INTERFACE_INFO of s_axi_awaddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI AWADDR";
    attribute X_INTERFACE_PARAMETER of s_axi_awaddr : signal is "PROTOCOL AXI4LITE, DATA_WIDTH 32, ADDR_WIDTH 4, FREQ_HZ 100000000, ID_WIDTH 0, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BRESP 1, HAS_RRESP 1, HAS_WSTRB 1";
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

    constant ADDR_LSB : integer := 2;

    signal awready_r        : std_logic := '0';
    signal wready_r         : std_logic := '0';
    signal bvalid_r         : std_logic := '0';
    signal arready_r        : std_logic := '0';
    signal rvalid_r         : std_logic := '0';
    signal bresp_r          : std_logic_vector(1 downto 0) := (others => '0');
    signal rresp_r          : std_logic_vector(1 downto 0) := (others => '0');
    signal rdata_r          : std_logic_vector(31 downto 0) := (others => '0');
    signal control_reg      : std_logic_vector(31 downto 0) := (others => '0');
    signal status_reg       : std_logic_vector(31 downto 0) := (others => '0');
    signal sample_count_reg : unsigned(31 downto 0) := (others => '0');
    signal last_sample_reg  : std_logic_vector(31 downto 0) := (others => '0');

    signal bclk_sync        : std_logic_vector(2 downto 0) := (others => '0');
    signal lrclk_sync       : std_logic_vector(2 downto 0) := (others => '0');
    signal recdat_sync      : std_logic_vector(2 downto 0) := (others => '0');
    signal prev_bclk        : std_logic := '0';
    signal prev_lrclk       : std_logic := '0';
    signal bit_count        : unsigned(5 downto 0) := (others => '0');
    signal current_channel  : std_logic := '0';
    signal shift_reg        : std_logic_vector(23 downto 0) := (others => '0');
    signal left_sample      : signed(23 downto 0) := (others => '0');
    signal right_sample     : signed(23 downto 0) := (others => '0');
    signal left_valid       : std_logic := '0';
    signal right_valid      : std_logic := '0';
    signal sample_seen      : std_logic := '0';
    signal overflow_seen    : std_logic := '0';
    signal tvalid_r         : std_logic := '0';
    signal tdata_r          : std_logic_vector(31 downto 0) := (others => '0');
begin
    s_axi_awready <= awready_r;
    s_axi_wready  <= wready_r;
    s_axi_bresp   <= bresp_r;
    s_axi_bvalid  <= bvalid_r;
    s_axi_arready <= arready_r;
    s_axi_rdata   <= rdata_r;
    s_axi_rresp   <= rresp_r;
    s_axi_rvalid  <= rvalid_r;

    ac_pbdat <= '0';
    ac_muten <= '0';
    m_axis_audio_tdata <= tdata_r;
    m_axis_audio_tvalid <= tvalid_r;

    axi_proc : process(aclk)
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

                if s_axi_awvalid = '1' and s_axi_wvalid = '1' and bvalid_r = '0' then
                    awready_r <= '1';
                    wready_r <= '1';
                    bvalid_r <= '1';
                    if s_axi_awaddr(ADDR_LSB+1 downto ADDR_LSB) = "00" then
                        control_reg <= s_axi_wdata;
                    end if;
                end if;

                if bvalid_r = '1' and s_axi_bready = '1' then
                    bvalid_r <= '0';
                end if;

                if s_axi_arvalid = '1' and rvalid_r = '0' then
                    arready_r <= '1';
                    rvalid_r <= '1';
                    case s_axi_araddr(ADDR_LSB+1 downto ADDR_LSB) is
                        when "00" => rdata_r <= control_reg;
                        when "01" => rdata_r <= status_reg;
                        when "10" => rdata_r <= std_logic_vector(sample_count_reg);
                        when others => rdata_r <= last_sample_reg;
                    end case;
                end if;

                if rvalid_r = '1' and s_axi_rready = '1' then
                    rvalid_r <= '0';
                end if;
            end if;
        end if;
    end process;

    sample_proc : process(aclk)
        variable mono_sum    : signed(24 downto 0);
        variable mono_sample : signed(23 downto 0);
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                bclk_sync <= (others => '0');
                lrclk_sync <= (others => '0');
                recdat_sync <= (others => '0');
                prev_bclk <= '0';
                prev_lrclk <= '0';
                bit_count <= (others => '0');
                current_channel <= '0';
                shift_reg <= (others => '0');
                left_sample <= (others => '0');
                right_sample <= (others => '0');
                left_valid <= '0';
                right_valid <= '0';
                sample_seen <= '0';
                overflow_seen <= '0';
                sample_count_reg <= (others => '0');
                last_sample_reg <= (others => '0');
                tvalid_r <= '0';
                tdata_r <= (others => '0');
                status_reg <= (others => '0');
            else
                bclk_sync <= bclk_sync(1 downto 0) & ac_bclk;
                lrclk_sync <= lrclk_sync(1 downto 0) & ac_reclrc;
                recdat_sync <= recdat_sync(1 downto 0) & ac_recdat;
                prev_bclk <= bclk_sync(2);
                prev_lrclk <= lrclk_sync(2);

                if control_reg(0) = '1' then
                    overflow_seen <= '0';
                end if;

                if tvalid_r = '1' and m_axis_audio_tready = '1' then
                    tvalid_r <= '0';
                end if;

                if lrclk_sync(2) /= prev_lrclk then
                    bit_count <= (others => '0');
                    shift_reg <= (others => '0');
                    current_channel <= lrclk_sync(2);
                elsif bclk_sync(2) = '1' and prev_bclk = '0' then
                    if bit_count < to_unsigned(24, bit_count'length) then
                        shift_reg <= shift_reg(22 downto 0) & recdat_sync(2);
                        bit_count <= bit_count + 1;
                        if bit_count = to_unsigned(23, bit_count'length) then
                            if current_channel = '0' then
                                left_sample <= signed(shift_reg(22 downto 0) & recdat_sync(2));
                                left_valid <= '1';
                            else
                                right_sample <= signed(shift_reg(22 downto 0) & recdat_sync(2));
                                right_valid <= '1';
                                if left_valid = '1' then
                                    mono_sum := resize(left_sample, 25) + resize(signed(shift_reg(22 downto 0) & recdat_sync(2)), 25);
                                    mono_sample := resize(shift_right(mono_sum, 1), 24);
                                    sample_seen <= '1';
                                    sample_count_reg <= sample_count_reg + 1;
                                    last_sample_reg <= std_logic_vector(resize(mono_sample, 32));
                                    if tvalid_r = '0' or m_axis_audio_tready = '1' then
                                        tdata_r <= std_logic_vector(resize(mono_sample, 32));
                                        tvalid_r <= '1';
                                    else
                                        overflow_seen <= '1';
                                    end if;
                                end if;
                            end if;
                        end if;
                    end if;
                end if;

                status_reg <= (31 downto 4 => '0') & right_valid & left_valid & sample_seen & overflow_seen;
            end if;
        end if;
    end process;
end architecture;


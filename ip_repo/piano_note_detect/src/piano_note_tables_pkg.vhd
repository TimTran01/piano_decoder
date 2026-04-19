library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package piano_note_tables_pkg is
    constant NOTE_COUNT : integer := 88;

    type signed32_array_t is array (natural range <>) of signed(31 downto 0);
    type unsigned32_array_t is array (natural range <>) of unsigned(31 downto 0);
    type unsigned8_array_t is array (natural range <>) of unsigned(7 downto 0);

    constant NOTE_COEFF_Q2_30 : signed32_array_t(0 to NOTE_COUNT-1) := (
        to_signed(2147469734, 32), to_signed(2147468030, 32), to_signed(2147466118, 32), to_signed(2147463971, 32),
        to_signed(2147461561, 32), to_signed(2147458857, 32), to_signed(2147455821, 32), to_signed(2147452413, 32),
        to_signed(2147448588, 32), to_signed(2147444294, 32), to_signed(2147439475, 32), to_signed(2147434065, 32),
        to_signed(2147427993, 32), to_signed(2147421178, 32), to_signed(2147413528, 32), to_signed(2147404941, 32),
        to_signed(2147395302, 32), to_signed(2147384483, 32), to_signed(2147372339, 32), to_signed(2147358708, 32),
        to_signed(2147343408, 32), to_signed(2147326234, 32), to_signed(2147306957, 32), to_signed(2147285320, 32),
        to_signed(2147261033, 32), to_signed(2147233771, 32), to_signed(2147203172, 32), to_signed(2147168825, 32),
        to_signed(2147130272, 32), to_signed(2147086998, 32), to_signed(2147038425, 32), to_signed(2146983904, 32),
        to_signed(2146922707, 32), to_signed(2146854017, 32), to_signed(2146776915, 32), to_signed(2146690372, 32),
        to_signed(2146593233, 32), to_signed(2146484199, 32), to_signed(2146361816, 32), to_signed(2146224447, 32),
        to_signed(2146070260, 32), to_signed(2145897195, 32), to_signed(2145702941, 32), to_signed(2145484906, 32),
        to_signed(2145240178, 32), to_signed(2144965492, 32), to_signed(2144657181, 32), to_signed(2144311132, 32),
        to_signed(2143922726, 32), to_signed(2143486784, 32), to_signed(2142997490, 32), to_signed(2142448321, 32),
        to_signed(2141831955, 32), to_signed(2141140178, 32), to_signed(2140363773, 32), to_signed(2139492400, 32),
        to_signed(2138514457, 32), to_signed(2137416931, 32), to_signed(2136185222, 32), to_signed(2134802957, 32),
        to_signed(2133251770, 32), to_signed(2131511069, 32), to_signed(2129557760, 32), to_signed(2127365953, 32),
        to_signed(2124906624, 32), to_signed(2122147244, 32), to_signed(2119051360, 32), to_signed(2115578130, 32),
        to_signed(2111681806, 32), to_signed(2107311157, 32), to_signed(2102408830, 32), to_signed(2096910639, 32),
        to_signed(2090744774, 32), to_signed(2083830935, 32), to_signed(2076079365, 32), to_signed(2067389793, 32),
        to_signed(2057650268, 32), to_signed(2046735880, 32), to_signed(2034507373, 32), to_signed(2020809627, 32),
        to_signed(2005470023, 32), to_signed(1988296680, 32), to_signed(1969076582, 32), to_signed(1947573589, 32),
        to_signed(1923526358, 32), to_signed(1896646205, 32), to_signed(1866614931, 32), to_signed(1833082687, 32)
    );

    constant NOTE_FREQ_Q16_16 : unsigned32_array_t(0 to NOTE_COUNT-1) := (
        to_unsigned(1802240, 32), to_unsigned(1909407, 32), to_unsigned(2022946, 32), to_unsigned(2143237, 32),
        to_unsigned(2270680, 32), to_unsigned(2405702, 32), to_unsigned(2548752, 32), to_unsigned(2700309, 32),
        to_unsigned(2860878, 32), to_unsigned(3030994, 32), to_unsigned(3211227, 32), to_unsigned(3402176, 32),
        to_unsigned(3604480, 32), to_unsigned(3818814, 32), to_unsigned(4045892, 32), to_unsigned(4286473, 32),
        to_unsigned(4541360, 32), to_unsigned(4811404, 32), to_unsigned(5097505, 32), to_unsigned(5400618, 32),
        to_unsigned(5721755, 32), to_unsigned(6061989, 32), to_unsigned(6422453, 32), to_unsigned(6804352, 32),
        to_unsigned(7208960, 32), to_unsigned(7637627, 32), to_unsigned(8091784, 32), to_unsigned(8572947, 32),
        to_unsigned(9082720, 32), to_unsigned(9622807, 32), to_unsigned(10195009, 32), to_unsigned(10801236, 32),
        to_unsigned(11443511, 32), to_unsigned(12123977, 32), to_unsigned(12844906, 32), to_unsigned(13608704, 32),
        to_unsigned(14417920, 32), to_unsigned(15275254, 32), to_unsigned(16183568, 32), to_unsigned(17145893, 32),
        to_unsigned(18165441, 32), to_unsigned(19245614, 32), to_unsigned(20390018, 32), to_unsigned(21602472, 32),
        to_unsigned(22887021, 32), to_unsigned(24247954, 32), to_unsigned(25689813, 32), to_unsigned(27217409, 32),
        to_unsigned(28835840, 32), to_unsigned(30550508, 32), to_unsigned(32367136, 32), to_unsigned(34291786, 32),
        to_unsigned(36330882, 32), to_unsigned(38491228, 32), to_unsigned(40780036, 32), to_unsigned(43204943, 32),
        to_unsigned(45774043, 32), to_unsigned(48495909, 32), to_unsigned(51379626, 32), to_unsigned(54434817, 32),
        to_unsigned(57671680, 32), to_unsigned(61101017, 32), to_unsigned(64734272, 32), to_unsigned(68583572, 32),
        to_unsigned(72661764, 32), to_unsigned(76982457, 32), to_unsigned(81560072, 32), to_unsigned(86409886, 32),
        to_unsigned(91548086, 32), to_unsigned(96991818, 32), to_unsigned(102759252, 32), to_unsigned(108869635, 32),
        to_unsigned(115343360, 32), to_unsigned(122202033, 32), to_unsigned(129468544, 32), to_unsigned(137167144, 32),
        to_unsigned(145323527, 32), to_unsigned(153964914, 32), to_unsigned(163120144, 32), to_unsigned(172819773, 32),
        to_unsigned(183096171, 32), to_unsigned(193983636, 32), to_unsigned(205518503, 32), to_unsigned(217739269, 32),
        to_unsigned(230686720, 32), to_unsigned(244404066, 32), to_unsigned(258937088, 32), to_unsigned(274334289, 32)
    );

    constant NOTE_MIDI : unsigned8_array_t(0 to NOTE_COUNT-1) := (
        to_unsigned(21, 8), to_unsigned(22, 8), to_unsigned(23, 8), to_unsigned(24, 8),
        to_unsigned(25, 8), to_unsigned(26, 8), to_unsigned(27, 8), to_unsigned(28, 8),
        to_unsigned(29, 8), to_unsigned(30, 8), to_unsigned(31, 8), to_unsigned(32, 8),
        to_unsigned(33, 8), to_unsigned(34, 8), to_unsigned(35, 8), to_unsigned(36, 8),
        to_unsigned(37, 8), to_unsigned(38, 8), to_unsigned(39, 8), to_unsigned(40, 8),
        to_unsigned(41, 8), to_unsigned(42, 8), to_unsigned(43, 8), to_unsigned(44, 8),
        to_unsigned(45, 8), to_unsigned(46, 8), to_unsigned(47, 8), to_unsigned(48, 8),
        to_unsigned(49, 8), to_unsigned(50, 8), to_unsigned(51, 8), to_unsigned(52, 8),
        to_unsigned(53, 8), to_unsigned(54, 8), to_unsigned(55, 8), to_unsigned(56, 8),
        to_unsigned(57, 8), to_unsigned(58, 8), to_unsigned(59, 8), to_unsigned(60, 8),
        to_unsigned(61, 8), to_unsigned(62, 8), to_unsigned(63, 8), to_unsigned(64, 8),
        to_unsigned(65, 8), to_unsigned(66, 8), to_unsigned(67, 8), to_unsigned(68, 8),
        to_unsigned(69, 8), to_unsigned(70, 8), to_unsigned(71, 8), to_unsigned(72, 8),
        to_unsigned(73, 8), to_unsigned(74, 8), to_unsigned(75, 8), to_unsigned(76, 8),
        to_unsigned(77, 8), to_unsigned(78, 8), to_unsigned(79, 8), to_unsigned(80, 8),
        to_unsigned(81, 8), to_unsigned(82, 8), to_unsigned(83, 8), to_unsigned(84, 8),
        to_unsigned(85, 8), to_unsigned(86, 8), to_unsigned(87, 8), to_unsigned(88, 8),
        to_unsigned(89, 8), to_unsigned(90, 8), to_unsigned(91, 8), to_unsigned(92, 8),
        to_unsigned(93, 8), to_unsigned(94, 8), to_unsigned(95, 8), to_unsigned(96, 8),
        to_unsigned(97, 8), to_unsigned(98, 8), to_unsigned(99, 8), to_unsigned(100, 8),
        to_unsigned(101, 8), to_unsigned(102, 8), to_unsigned(103, 8), to_unsigned(104, 8),
        to_unsigned(105, 8), to_unsigned(106, 8), to_unsigned(107, 8), to_unsigned(108, 8)
    );
end package;

package body piano_note_tables_pkg is
end package body;


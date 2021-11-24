----------------------------------------------------------------------------
--  color_matrix.vhd
--	Color Correction Matrix
--	Version 1.0
--
--  SPDX-FileCopyrightText: © 2014 Herbert Poetzl <herbert@13thfloor.at>
--  SPDX-License-Identifier: GPL-2.0-or-later
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;

package vec_mat_pkg is

    type vec1_a is array (natural range <>) of
	std_logic;

    type vec2_a is array (natural range <>) of
	std_logic_vector (1 downto 0);

    type vec4_a is array (natural range <>) of
	std_logic_vector (3 downto 0);

    type vec8_a is array (natural range <>) of
	std_logic_vector (7 downto 0);

    type vec9_a is array (natural range <>) of
	std_logic_vector (8 downto 0);

    type vec10_a is array (natural range <>) of
	std_logic_vector (9 downto 0);

    type vec12_a is array (natural range <>) of
	std_logic_vector (11 downto 0);

    type vec16_a is array (natural range <>) of
	std_logic_vector (15 downto 0);

    type vec18_a is array (natural range <>) of
	std_logic_vector (17 downto 0);

    type vec24_a is array (natural range <>) of
	std_logic_vector (23 downto 0);

    type vec25_a is array (natural range <>) of
	std_logic_vector (24 downto 0);

    type vec30_a is array (natural range <>) of
	std_logic_vector (29 downto 0);

    type vec32_a is array (natural range <>) of
	std_logic_vector (31 downto 0);

    type vec48_a is array (natural range <>) of
	std_logic_vector (47 downto 0);

    subtype vec1_3  is vec1_a  (0 to 2);
    subtype vec2_3  is vec2_a  (0 to 2);
    subtype vec8_3  is vec8_a  (0 to 2);
    subtype vec9_3  is vec9_a  (0 to 2);
    subtype vec12_3 is vec12_a (0 to 2);
    subtype vec16_3 is vec16_a (0 to 2);
    subtype vec18_3 is vec18_a (0 to 2);
    subtype vec24_3 is vec24_a (0 to 2);
    subtype vec25_3 is vec25_a (0 to 2);
    subtype vec30_3 is vec30_a (0 to 2);
    subtype vec32_3 is vec32_a (0 to 2);
    subtype vec48_3 is vec48_a (0 to 2);

    type mat1_3x3  is array (0 to 2) of vec1_3;
    type mat2_3x3  is array (0 to 2) of vec2_3;
    type mat8_3x3  is array (0 to 2) of vec8_3;
    type mat9_3x3  is array (0 to 2) of vec9_3;
    type mat12_3x3 is array (0 to 2) of vec12_3;
    type mat16_3x3 is array (0 to 2) of vec16_3;
    type mat18_3x3 is array (0 to 2) of vec18_3;
    type mat24_3x3 is array (0 to 2) of vec24_3;
    type mat25_3x3 is array (0 to 2) of vec25_3;
    type mat30_3x3 is array (0 to 2) of vec30_3;
    type mat32_3x3 is array (0 to 2) of vec32_3;
    type mat48_3x3 is array (0 to 2) of vec48_3;

    subtype vec1_4  is vec1_a  (0 to 3);
    subtype vec2_4  is vec2_a  (0 to 3);
    subtype vec8_4  is vec8_a  (0 to 3);
    subtype vec9_4  is vec9_a  (0 to 3);
    subtype vec12_4 is vec12_a (0 to 3);
    subtype vec16_4 is vec16_a (0 to 3);
    subtype vec18_4 is vec18_a (0 to 3);
    subtype vec24_4 is vec24_a (0 to 3);
    subtype vec25_4 is vec25_a (0 to 3);
    subtype vec30_4 is vec30_a (0 to 3);
    subtype vec32_4 is vec32_a (0 to 3);
    subtype vec48_4 is vec48_a (0 to 3);

    type mat1_4x4  is array (0 to 3) of vec1_4;
    type mat2_4x4  is array (0 to 3) of vec2_4;
    type mat8_4x4  is array (0 to 3) of vec8_4;
    type mat9_4x4  is array (0 to 3) of vec9_4;
    type mat12_4x4 is array (0 to 3) of vec12_4;
    type mat16_4x4 is array (0 to 3) of vec16_4;
    type mat18_4x4 is array (0 to 3) of vec18_4;
    type mat24_4x4 is array (0 to 3) of vec24_4;
    type mat25_4x4 is array (0 to 3) of vec25_4;
    type mat30_4x4 is array (0 to 3) of vec30_4;
    type mat32_4x4 is array (0 to 3) of vec32_4;
    type mat48_4x4 is array (0 to 3) of vec48_4;

end vec_mat_pkg;


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.vec_mat_pkg.ALL;	-- Vector/Matrix


entity color_mat_4x4 is
    port (
	clk	: in std_logic;
	clip	: in std_logic_vector (1 downto 0);
	bypass	: in std_logic := '0';
	--
	matrix	: in mat16_4x4;
	adjust	: in mat16_4x4;
	offset	: in vec16_4;
	--
	v_in	: in vec12_4;
	v_out	: out vec12_4
    );
end entity color_mat_4x4;


architecture RTL of color_mat_4x4 is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal a_30 : mat30_4x4 := (others => (others => (others => '0')));
    signal b_18 : mat18_4x4 := (others => (others => (others => '0')));
    signal c_48 : mat48_4x4 := (others => (others => (others => '0')));
    signal d_25 : vec25_4 := (others => (others => '0'));

    type vec12_4a is array (natural range <>) of vec12_4;

    signal v_in_d : vec12_4a (0 to 6);

    alias v_in_d1 : std_logic_vector (11 downto 0) is v_in_d(5)(1);
    alias v_in_d2 : std_logic_vector (11 downto 0) is v_in_d(3)(2);
    alias v_in_d3 : std_logic_vector (11 downto 0) is v_in_d(1)(3);

    signal p_48 : mat48_4x4 := (others => (others => (others => '0')));

    signal pat : mat1_4x4 := (others => (others => '0'));

    signal reset : std_logic_vector (4 downto 0) := (others => '1');

begin

    reset_proc : process (clk)
    begin
	if rising_edge(clk) then
	    reset <= '0' & reset(reset'high downto 1);
	end if;
    end process;

    --	A B C D		A'B'C'D'	M		P
    -------------------------------------------------------------------
    --	0 0 0 0		- - - -		-		-
    --	1 1 1 1		0 0 0 0		-		-
    --	2 2 2 2		1 1 1 1		B0x(D0+A0)	-
    --	3 3 3 3		2 2 2 2		B1x(D1+A1)	B0x(D0+A0)+C1
    -------------------------------------------------------------------

    delay_proc : process (clk)
    begin
	if rising_edge(clk) then
	    for I in 0 to 5 loop
		v_in_d(I) <= v_in_d(I+1);
	    end loop;
	    v_in_d(6) <= v_in;
	end if;
    end process;


    GEN_OFF: for I in 0 to 3 generate
	c_48(I)(0) <= std_logic_vector(
	    resize(signed(offset(I)), 40)) & x"00";

	v_out(I) <= v_in_d(0)(I) when bypass
	    else (others => '0') when p_48(I)(3)(47) = '1' and clip(0) = '1'
	    else (others => '1') when pat(I)(3) = '0' and clip(1) = '1'
	    else p_48(I)(3)(19 downto 8);

	--v_out(I) <= p_48(I)(3)(15 downto 0);
	-- v_out(I) <= p_48(I)(3)(47 downto 32);
    end generate;

    d_25(0) <= std_logic_vector(resize(unsigned(v_in(0)), 25));
    d_25(1) <= std_logic_vector(resize(unsigned(v_in_d1), 25));
    d_25(2) <= std_logic_vector(resize(unsigned(v_in_d2), 25));
    d_25(3) <= std_logic_vector(resize(unsigned(v_in_d3), 25));

--  GEN_IN: for J in 0 to 3 generate
--	d_25(J) <= std_logic_vector(resize(signed(v_in(J)), 25));
--  end generate;

    GEN_MATI: for I in 0 to 3 generate
	GEN_MATJ: for J in 0 to 3 generate

	    a_30(I)(J) <= std_logic_vector(resize(signed(adjust(I)(J)), 30));
	    b_18(I)(J) <= std_logic_vector(resize(signed(matrix(I)(J)), 18));

	    CASCADE: if J > 0 generate
		c_48(I)(J) <= std_logic_vector(
		    resize(signed(p_48(I)(J - 1)(42 downto 0)), 48));
	    end generate;

	    DSP48E1_matrix : entity work.dsp48_wrap
		generic map (
		    AREG => 1,			-- Pipeline stages for A (0, 1 or 2)
		    BREG => 1,			-- Pipeline stages for B (0, 1 or 2)
		    CREG => 1,			-- Pipeline stages for C (0 or 1)
		    DREG => 1,			-- Pipeline stages for D (0 or 1)
		    PREG => 1,			-- Pipeline stages for P (0 or 1)
		    MREG => 1,			-- Pipeline stages for M (0 or 1)
		    ACASCREG => 1,		-- Pipeline stages A/ACIN to ACOUT (0, 1 or 2)
		    BCASCREG => 1,		-- Pipeline stages B/BCIN to BCOUT (0, 1 or 2)
		    USE_DPORT => true,		-- Activate preadder (FALSE, TRUE)
		    USE_PATTERN_DETECT => "PATDET", -- ("PATDET" or "NO_PATDET")
		    MASK => x"8000000FFFFF",	-- 48-bit mask value for pattern detect (1=ignore)
		    PATTERN => x"000000000000",	-- 48-bit pattern match for pattern detect
		    USE_MULT => "MULTIPLY" )	-- "NONE", "MULTIPLY", "DYNAMIC"
		port map (
		    CLK => clk,			-- 1-bit input: Clock input
		    A => a_30(I)(J),		-- 30-bit input: A data input
		    B => b_18(I)(J),		-- 18-bit input: B data input
		    C => c_48(I)(J),		-- 48-bit input: C data input
		    D => d_25(J),		-- 25-bit input: D data input
		    ALUMODE => "0000",		-- 4-bit input: ALU control input
		    INMODE => "10101",		-- 5-bit input: INMODE control input
		    OPMODE => "0110101",	-- 7-bit input: Operation mode input
		    RSTM => reset(0),		-- 1-bit input: Reset input for MREG
		    RSTP => reset(0),		-- 1-bit input: Reset input for PREG
		    CEA1 => '1',		-- 1-bit input: CE input for 1st stage AREG
		    CEB1 => '1',		-- 1-bit input: CE input for 1st stage BREG
		    CEC => '1',			-- 1-bit input: CE input for CREG
		    CED => '1',			-- 1-bit input: CE input for DREG
		    CEM => '1',			-- 1-bit input: CE input for MREG
		    CEP => '1',			-- 1-bit input: CE input for PREG
		    --
		    P => p_48(I)(J),		-- 48-bit output: Primary data output
		    PATTERNDETECT => pat(I)(J) );

	end generate;
    end generate;

end RTL;

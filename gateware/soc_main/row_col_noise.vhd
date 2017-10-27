----------------------------------------------------------------------------
--  row_col_noise.vhd
--	Correct Row/Col Noise
--	Version 1.3
--
--  Copyright (C) 2014-2016 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes

entity row_col_noise is
    port (
	clk	: in std_logic;
	clip	: in std_logic_vector (1 downto 0);
	--
	ch0_in	: in std_logic_vector (17 downto 0);
	ch1_in	: in std_logic_vector (17 downto 0);
	ch2_in	: in std_logic_vector (17 downto 0);
	ch3_in	: in std_logic_vector (17 downto 0);
	--
	c0r0_lut : in std_logic_vector (11 downto 0);
	c1r0_lut : in std_logic_vector (11 downto 0);
	c0r1_lut : in std_logic_vector (11 downto 0);
	c1r1_lut : in std_logic_vector (11 downto 0);
	--
	r0_lut	: in std_logic_vector (11 downto 0);
	r1_lut	: in std_logic_vector (11 downto 0);
	--
	ch0_out	: out std_logic_vector (15 downto 0);
	ch1_out	: out std_logic_vector (15 downto 0);
	ch2_out	: out std_logic_vector (15 downto 0);
	ch3_out	: out std_logic_vector (15 downto 0)
    );
end entity row_col_noise;


architecture RTL of row_col_noise is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal ch0_res : std_logic_vector (15 downto 0);
    signal ch1_res : std_logic_vector (15 downto 0);
    signal ch2_res : std_logic_vector (15 downto 0);
    signal ch3_res : std_logic_vector (15 downto 0);

    signal ab0 : std_logic_vector (47 downto 0);

    alias a0 : std_logic_vector (29 downto 0) is ab0(47 downto 18);
    alias b0 : std_logic_vector (17 downto 0) is ab0(17 downto 0);

    alias ab0_v0 : std_logic_vector (11 downto 0) is ab0(11 downto 0);
    alias ab0_v1 : std_logic_vector (11 downto 0) is ab0(23 downto 12);
    alias ab0_v2 : std_logic_vector (11 downto 0) is ab0(35 downto 24);
    alias ab0_v3 : std_logic_vector (11 downto 0) is ab0(47 downto 36);

    signal c0 : std_logic_vector (47 downto 0);

    alias c0_v0 : std_logic_vector (11 downto 0) is c0(11 downto 0);
    alias c0_v1 : std_logic_vector (11 downto 0) is c0(23 downto 12);
    alias c0_v2 : std_logic_vector (11 downto 0) is c0(35 downto 24);
    alias c0_v3 : std_logic_vector (11 downto 0) is c0(47 downto 36);

    signal p0 : std_logic_vector (47 downto 0);
    signal flags0 : std_logic_vector (3 downto 0);

    alias p0_v0 : std_logic_vector (11 downto 0) is p0(11 downto 0);
    alias p0_v1 : std_logic_vector (11 downto 0) is p0(23 downto 12);
    alias p0_v2 : std_logic_vector (11 downto 0) is p0(35 downto 24);
    alias p0_v3 : std_logic_vector (11 downto 0) is p0(47 downto 36);


    signal ab1 : std_logic_vector (47 downto 0);

    alias a1 : std_logic_vector (29 downto 0) is ab1(47 downto 18);
    alias b1 : std_logic_vector (17 downto 0) is ab1(17 downto 0);

    alias ab1_v0 : std_logic_vector (23 downto 0) is ab1(23 downto 0);
    alias ab1_v1 : std_logic_vector (23 downto 0) is ab1(47 downto 24);

    signal c1 : std_logic_vector (47 downto 0);

    alias c1_v0 : std_logic_vector (23 downto 0) is c1(23 downto 0);
    alias c1_v1 : std_logic_vector (23 downto 0) is c1(47 downto 24);

    signal p1 : std_logic_vector (47 downto 0);
    signal flags1 : std_logic_vector (3 downto 0);

    alias p1_v0 : std_logic_vector (23 downto 0) is p1(23 downto 0);
    alias p1_v1 : std_logic_vector (23 downto 0) is p1(47 downto 24);


    signal ab2 : std_logic_vector (47 downto 0);

    alias a2 : std_logic_vector (29 downto 0) is ab2(47 downto 18);
    alias b2 : std_logic_vector (17 downto 0) is ab2(17 downto 0);

    alias ab2_v0 : std_logic_vector (23 downto 0) is ab2(23 downto 0);
    alias ab2_v1 : std_logic_vector (23 downto 0) is ab2(47 downto 24);

    signal c2 : std_logic_vector (47 downto 0);

    alias c2_v0 : std_logic_vector (23 downto 0) is c2(23 downto 0);
    alias c2_v1 : std_logic_vector (23 downto 0) is c2(47 downto 24);

    signal p2 : std_logic_vector (47 downto 0);
    signal flags2 : std_logic_vector (3 downto 0);

    alias p2_v0 : std_logic_vector (23 downto 0) is p2(23 downto 0);
    alias p2_v1 : std_logic_vector (23 downto 0) is p2(47 downto 24);

    function invmsb (v : std_logic_vector)
    	return std_logic_vector is
    begin
	return not v(v'high) & v(v'high - 1 downto 0);
    end function;


begin
    ab0_v0 <= invmsb(c0r0_lut);
    ab0_v1 <= invmsb(c1r0_lut);
    ab0_v2 <= invmsb(c0r1_lut);
    ab0_v3 <= invmsb(c1r1_lut);

    c0_v0 <= invmsb(r0_lut);
    c0_v1 <= invmsb(r0_lut);
    c0_v2 <= invmsb(r1_lut);
    c0_v3 <= invmsb(r1_lut);

    DSP48E1_row_col : entity work.dsp48_wrap
	generic map (
	    PREG => 1,			-- Pipeline stages for P (0 or 1)
	    USE_SIMD => "FOUR12" )	-- SIMD selection ("ONE48", "TWO24", "FOUR12")
	port map (
	    CLK => clk,			-- 1-bit input: Clock input
	    A => a0,			-- 30-bit input: A data input
	    B => b0,			-- 18-bit input: B data input
	    C => c0,			-- 48-bit input: C data input
	    ALUMODE => "0000",		-- 4-bit input: ALU control input
	    OPMODE => "0110011",	-- 7-bit input: Operation mode input
	    CEP => '1',			-- 1-bit input: CE input for PREG
	    --
	    P => p0,			-- 48-bit output: Primary data output
	    CARRYOUT => flags0 );	-- 4-bit carry output

    ab1_v0 <= std_logic_vector(resize(signed(
	not flags0(0) & p0_v0 & "00"), ab1_v0'length));
    ab1_v1 <= std_logic_vector(resize(signed(
	not flags0(1) & p0_v1 & "00"), ab1_v1'length));

    c1_v0 <= std_logic_vector(resize(signed(ch0_in), c1_v0'length));
    c1_v1 <= std_logic_vector(resize(signed(ch1_in), c1_v1'length));

    DSP48E1_ch0_ch1 : entity work.dsp48_wrap
	generic map (
	    PREG => 1,			-- Pipeline stages for P (0 or 1)
	    USE_SIMD => "TWO24" )	-- SIMD selection ("ONE48", "TWO24", "FOUR12")
	port map (
	    CLK => clk,			-- 1-bit input: Clock input
	    A => a1,			-- 30-bit input: A data input
	    B => b1,			-- 18-bit input: B data input
	    C => c1,			-- 48-bit input: C data input
	    ALUMODE => "0000",		-- 4-bit input: ALU control input
	    OPMODE => "0110011",	-- 7-bit input: Operation mode input
	    CEP => '1',			-- 1-bit input: CE input for PREG
	    --
	    P => p1,			-- 48-bit output: Primary data output
	    CARRYOUT => flags1 );	-- 4-bit carry output

    ch0_out <= ch0_res;
    ch0_res <=
	(others => '0') when p1_v0(23) = '1' and clip(0) = '1' else
	(others => '1') when p1_v0(16) = '1' and clip(1) = '1' else
	std_logic_vector(resize(unsigned(p1_v0), ch0_out'length));
    ch1_out <= ch1_res;
    ch1_res <=
	(others => '0') when p1_v1(23) = '1' and clip(0) = '1' else
	(others => '1') when p1_v1(16) = '1' and clip(1) = '1' else
	std_logic_vector(resize(unsigned(p1_v1), ch1_out'length));

    ab2_v0 <= std_logic_vector(resize(signed(
	not flags0(2) & p0_v2 & "00"), ab2_v0'length));
    ab2_v1 <= std_logic_vector(resize(signed(
	not flags0(3) & p0_v3 & "00"), ab2_v1'length));

    c2_v0 <= std_logic_vector(resize(signed(ch2_in), c2_v0'length));
    c2_v1 <= std_logic_vector(resize(signed(ch3_in), c2_v1'length));

    DSP48E1_ch2_ch3 : entity work.dsp48_wrap
	generic map (
	    PREG => 1,			-- Pipeline stages for P (0 or 1)
	    USE_SIMD => "TWO24" )	-- SIMD selection ("ONE48", "TWO24", "FOUR12")
	port map (
	    CLK => clk,			-- 1-bit input: Clock input
	    A => a2,			-- 30-bit input: A data input
	    B => b2,			-- 18-bit input: B data input
	    C => c2,			-- 48-bit input: C data input
	    ALUMODE => "0000",		-- 4-bit input: ALU control input
	    OPMODE => "0110011",	-- 7-bit input: Operation mode input
	    CEP => '1',			-- 1-bit input: CE input for PREG
	    --
	    P => p2,			-- 48-bit output: Primary data output
	    CARRYOUT => flags2 );	-- 4-bit carry output

    ch2_out <= ch2_res;
    ch2_res <=
	(others => '0') when p2_v0(23) = '1' and clip(0) = '1' else
	(others => '1') when p2_v0(16) = '1' and clip(1) = '1' else
	std_logic_vector(resize(unsigned(p2_v0), ch2_out'length));
    ch3_out <= ch3_res;
    ch3_res <=
	(others => '0') when p2_v1(23) = '1' and clip(0) = '1' else
	(others => '1') when p2_v1(16) = '1' and clip(1) = '1' else
	std_logic_vector(resize(unsigned(p2_v1), ch3_out'length));

end RTL;

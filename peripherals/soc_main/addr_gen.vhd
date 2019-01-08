----------------------------------------------------------------------------
--  addr_gen.vhd
--	Address Generator
--	Version 1.5
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes


entity addr_gen is
    generic (
	COUNT_WIDTH : natural := 12;
	ADDR_WIDTH : natural := 32 );
    port (
	clk	: in std_logic;			-- base clock
	load	: in std_logic;			-- load
	enable	: in std_logic;			-- enable
	--
	addr_in : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	col_inc : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	col_cnt : in std_logic_vector (COUNT_WIDTH - 1 downto 0);
	--
	row_inc : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	pattern : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	addr	: out std_logic_vector (ADDR_WIDTH - 1 downto 0);
	match	: out std_logic
    );

end entity addr_gen;


architecture RTL of addr_gen is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal ccnt : unsigned(COUNT_WIDTH downto 0) := (others => '0');

    alias ccnt_high : std_logic is ccnt(COUNT_WIDTH);

    signal pat_c : std_logic_vector (47 downto 0)
	:= (others => '0');
    signal ab_in : std_logic_vector (47 downto 0)
	:= (others => '0');

    alias inc_a : std_logic_vector (29 downto 0)
	is ab_in(47 downto 18);

    alias inc_b : std_logic_vector (17 downto 0)
	is ab_in(17 downto 0);

    signal opmode : std_logic_vector (6 downto 0);

    signal p_out : std_logic_vector (47 downto 0);

    signal detect : std_logic;
    signal active : std_logic;
    signal first : std_logic;

begin

    ccnt_proc: process (clk)
    begin
	if rising_edge(clk) then
	    if load = '1' then
		ccnt(col_cnt'range) <= unsigned(col_cnt);
		ccnt_high <= '0';
		first <= '1';

	    elsif enable = '1' then
		if ccnt_high = '1' then
		    ccnt(col_cnt'range) <= unsigned(col_cnt);
		    ccnt_high <= '0';

		else
		    ccnt <= ccnt - "1";

		end if;
		first <= '0';
	    end if;
	end if;
    end process;

    pat_c(addr_in'range) <= addr_in
	when load = '1' else pattern;

    ab_in(col_inc'range) <= col_inc
	when ccnt_high = '0' else row_inc;

    opmode <= "0110000" when load = '1' else "0100011";

    DSP48_addr_inst : entity work.dsp48_wrap
	generic map (
	    PREG => 1,				-- Pipeline stages for P (0 or 1)
	    MASK => x"000000000000",		-- 48-bit mask value for pattern detect
	    SEL_PATTERN => "C",			-- Select pattern value ("PATTERN" or "C")
	    USE_PATTERN_DETECT => "PATDET",	-- ("PATDET" or "NO_PATDET")
	    USE_SIMD => "ONE48" )		-- SIMD selection ("ONE48", "TWO24", "FOUR12")
	port map (
	    CLK => clk,				-- 1-bit input: Clock input
	    A => inc_a,				-- 30-bit input: A data input
	    B => inc_b,				-- 18-bit input: B data input
	    C => pat_c,				-- 48-bit input: C data input
	    OPMODE => opmode,			-- 7-bit input: Operation mode input
	    ALUMODE => "0000",			-- 7-bit input: Operation mode input
	    CARRYIN => '0',			-- 1-bit input: Carry input signal
	    CEP => active,			-- 1-bit input: CE input for PREG
	    --
	    PATTERNDETECT => detect,		-- Match indicator P[47:0] with pattern
	    P => p_out );			-- 48-bit output: Primary data output

    match <= detect and not first;
    active <= load or enable;
    addr <= p_out(addr'range);

end RTL;

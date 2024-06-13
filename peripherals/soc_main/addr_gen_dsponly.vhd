----------------------------------------------------------------------------
--  addr_gen.vhd
--	Address Generator
--	Version 2.0
--
--  Copyright (C) 2013-2020 H.Poetzl
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
	ACNT_WIDTH : natural := 12;
	ADDR_WIDTH : natural := 32 );
    port (
	clk	: in std_logic;			-- base clock
	update	: in std_logic;			-- register inputs 
	load	: in std_logic;			-- load
	enable	: in std_logic;			-- enable
	--
	acnt_in : in std_logic_vector (ACNT_WIDTH - 1 downto 0);
	addr_in : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	acnt_col_inc : in std_logic_vector (ACNT_WIDTH - 1 downto 0);
	addr_col_inc : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	acnt_row_inc : in std_logic_vector (ACNT_WIDTH - 1 downto 0);
	addr_row_inc : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	pattern : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	addr	: out std_logic_vector (ADDR_WIDTH - 1 downto 0);
	match	: out std_logic_vector (3 downto 0)
    );

end entity addr_gen;


architecture DSP of addr_gen is

    attribute KEEP_HIERARCHY of DSP : architecture is "TRUE";

    signal acnt_in_r : std_logic_vector (ACNT_WIDTH - 1 downto 0)
	:= (others => '0');
    signal addr_in_r : std_logic_vector (ADDR_WIDTH - 1 downto 0)
	:= (others => '0');

    signal acnt_col_inc_r : std_logic_vector (ACNT_WIDTH - 1 downto 0)
	:= (others => '0');
    signal addr_col_inc_r : std_logic_vector (ADDR_WIDTH - 1 downto 0)
	:= (others => '0');

    signal acnt_row_inc_r : std_logic_vector (ACNT_WIDTH - 1 downto 0)
	:= (others => '0');
    signal addr_row_inc_r : std_logic_vector (ADDR_WIDTH - 1 downto 0)
	:= (others => '0');

    signal pattern_r : std_logic_vector (ADDR_WIDTH - 1 downto 0)
	:= (others => '1');

    constant ZGAP_WIDTH : integer := 48 - ACNT_WIDTH - ADDR_WIDTH;
    constant ZGAP : std_logic_vector (ZGAP_WIDTH - 1 downto 0)
	:= (others => '0');

    constant ZPAD_WIDTH : integer := 48 - ADDR_WIDTH;
    constant ZPAD : std_logic_vector (ZPAD_WIDTH - 1 downto 0)
	:= (others => '0');

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

    signal carry : std_logic_vector (3 downto 0);
    signal overflow : std_logic;
    signal underflow : std_logic;

    signal detect : std_logic;
    signal active : std_logic;
    signal first : std_logic;

begin

    first_proc: process (clk)
    begin
	if rising_edge(clk) then
	    if update = '1' then
		acnt_in_r <= acnt_in;
		addr_in_r <= addr_in;
		acnt_col_inc_r <= acnt_col_inc;
		addr_col_inc_r <= addr_col_inc;
		acnt_row_inc_r <= acnt_row_inc;
		addr_row_inc_r <= addr_row_inc;
		pattern_r <= pattern;
		
	    elsif load = '1' then
		first <= '1';

	    elsif enable = '1' then
		first <= '0';
	    end if;
	end if;
    end process;

    pat_c <= acnt_in_r & ZGAP & addr_in_r
	when load = '1' 
	else ZPAD & pattern_r;

    ab_in <= acnt_col_inc_r & ZGAP & addr_col_inc_r
	when carry(3) = '0' 
	else acnt_row_inc_r & ZGAP & addr_row_inc_r;

    opmode <= "0110000" when load = '1' else "0100011";

    DSP48_addr_inst : entity work.dsp48_wrap
	generic map (
	    PREG => 1,				-- Pipeline stages for P (0 or 1)
	    MASK => x"000000000000",		-- 48-bit mask value for pattern detect
	    SEL_PATTERN => "C",			-- Select pattern value ("PATTERN" or "C")
	    USE_PATTERN_DETECT => "PATDET",	-- ("PATDET" or "NO_PATDET")
	    USE_DPORT => FALSE,			-- Disable D Port to save power
	    USE_MULT => "NONE",			-- Disable Multiplier to save power
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
	    CARRYOUT => carry,
	    UNDERFLOW => underflow,
	    OVERFLOW => overflow,
	    P => p_out );			-- 48-bit output: Primary data output

    match <= carry(3) & overflow & first & detect;
    active <= load or enable;
    addr <= p_out(addr'range);

end DSP;

----------------------------------------------------------------------------
--  scan_comp.vhd
--	Scan Comparator
--	Version 1.0
--
--  Copyright (C) 2014 H.Poetzl
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

entity scan_comp is
    port (
	clk	: in std_logic;
	reset_n	: in std_logic;
	--
	a0	: in std_logic_vector(11 downto 0);
	a1	: in std_logic_vector(11 downto 0);
	a2	: in std_logic_vector(11 downto 0);
	a3	: in std_logic_vector(11 downto 0);
	--
	b0	: in std_logic_vector(11 downto 0);
	b1	: in std_logic_vector(11 downto 0);
	b2	: in std_logic_vector(11 downto 0);
	b3	: in std_logic_vector(11 downto 0);
	--
	flags	: out std_logic_vector(3 downto 0)
    );
end entity scan_comp;


architecture RTL of scan_comp is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal ab : std_logic_vector(47 downto 0);

    alias a : std_logic_vector(29 downto 0) is ab(47 downto 18);
    alias b : std_logic_vector(17 downto 0) is ab(17 downto 0);

    alias ab_v0 : std_logic_vector(11 downto 0) is ab(11 downto 0);
    alias ab_v1 : std_logic_vector(11 downto 0) is ab(23 downto 12);
    alias ab_v2 : std_logic_vector(11 downto 0) is ab(35 downto 24);
    alias ab_v3 : std_logic_vector(11 downto 0) is ab(47 downto 36);

    signal c : std_logic_vector(47 downto 0);

    alias c_v0 : std_logic_vector(11 downto 0) is c(11 downto 0);
    alias c_v1 : std_logic_vector(11 downto 0) is c(23 downto 12);
    alias c_v2 : std_logic_vector(11 downto 0) is c(35 downto 24);
    alias c_v3 : std_logic_vector(11 downto 0) is c(47 downto 36);

begin

    ab_v0 <= a0;
    ab_v1 <= a1;
    ab_v2 <= a2;
    ab_v3 <= a3;

    c_v0 <= b0;
    c_v1 <= b1;
    c_v2 <= b2;
    c_v3 <= b3;

    DSP48E1_comp_inst : entity work.dsp48_wrap
	generic map (
	    USE_SIMD => "FOUR12" )	-- SIMD selection ("ONE48", "TWO24", "FOUR12")
	port map (
	    CLK => clk,			-- 1-bit input: Clock input
	    A => a,			-- 30-bit input: A data input
	    B => b,			-- 18-bit input: B data input
	    C => c,			-- 48-bit input: C data input
	    ALUMODE => "0011",		-- 4-bit input: ALU control input
	    OPMODE => "0110011",	-- 7-bit input: Operation mode input
	    --
	    CARRYOUT => flags );	-- 4-bit carry output

end RTL;

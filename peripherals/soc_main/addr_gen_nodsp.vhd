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
use IEEE.std_logic_unsigned.all;

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

    signal detect : std_logic := '0';
    signal ccnt : std_logic_vector(COUNT_WIDTH - 1 downto 0) := (others => '0');
    signal addr_accum : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');

begin

    ccnt_proc: process (clk)
    begin
	if rising_edge(clk) then
	    if load = '1' then
		ccnt <= (others => '1');
		addr_accum <= addr_in;
		detect <= '0';

	    elsif enable = '1' then
		if ccnt  = col_cnt then
		    ccnt <= (others => '1');
		    addr_accum <= addr_accum + row_inc;

		else
		    addr_accum <= addr_accum + col_inc;
		    ccnt <= ccnt + "1";

		end if;
		if addr_accum = pattern then
		    detect <= '1';

		end if; 
	    end if;
	end if;
    end process;

    addr <= addr_accum;
    match <= detect;

end RTL;

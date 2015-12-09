----------------------------------------------------------------------------
--  par_match.vhd (for cmv_io2)
--	N-Channel Pattern Match
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

library unimacro;
use unimacro.VCOMPONENTS.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.par_array_pkg.ALL;	-- Parallel Data


entity par_match is
    generic (
	CHANNELS : natural := 32
    );
    port (
	par_clk		: in  std_logic;
	par_data	: in  par12_a (CHANNELS - 1 downto 0);
	--
	pattern		: in  par12_a (CHANNELS - 1 downto 0);
	--
	match		: out std_logic_vector (CHANNELS - 1 downto 0);
	mismatch	: out std_logic_vector (CHANNELS - 1 downto 0)
    );

end entity par_match;


architecture RTL of par_match is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

begin

    GEN_match : for I in CHANNELS - 1 downto 0 generate

	match_proc : process (par_clk)
	    variable shift_v : std_logic_vector (7 downto 0);
	begin
	    if rising_edge(par_clk) then
		if par_data(I) = pattern(I) then
		    shift_v := '1' & shift_v(shift_v'high downto 1);
		else
		    shift_v := '0' & shift_v(shift_v'high downto 1);
		end if;
	    end if;
	
	    if shift_v = x"FF" then
		match(I) <= '1';
	    else
		match(I) <= '0';
	    end if;
	
	    if shift_v = x"00" then
		mismatch(I) <= '1';
	    else
		mismatch(I) <= '0';
	    end if;
	end process;

    end generate;

end RTL;

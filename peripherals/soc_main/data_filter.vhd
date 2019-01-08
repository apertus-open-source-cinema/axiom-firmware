----------------------------------------------------------------------------
--  data_filter.vhd
--	FIFO Data Filter
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

library unimacro;
use unimacro.VCOMPONENTS.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes


entity data_filter is
    port (
	clk	 : in  std_logic;
	enable	 : in  std_logic;
	--
	en_in	 : in  std_logic;
	data_in	 : in  std_logic_vector (63 downto 0);
	--
	en_out	 : out std_logic;
	data_out : out std_logic_vector (63 downto 0)
    );

end entity data_filter;


architecture RTL of data_filter is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

begin

    enable_proc : process (clk)
    begin
	if rising_edge(clk) then
	    en_out <= en_in and enable;
	    data_out <= data_in;
	end if;
    end process;

end RTL;

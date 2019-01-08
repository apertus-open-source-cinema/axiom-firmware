----------------------------------------------------------------------------
--  data_sync.vhd
--	Data Synchronizer (N-Flop)
--	Version 1.1
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

use work.vivado_pkg.ALL;	-- Vivado Attributes


entity data_sync is
    generic (
	INIT_OUT : std_logic := '0';
	STAGES : natural := 2
    );
    port (
	clk : in std_logic;			-- Target Clock
	async_in : in std_logic;		-- Async Input
	sync_out : out std_logic		-- Sync Output
    );
end entity data_sync;


architecture RTL of data_sync is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal shift : std_logic_vector (STAGES downto 1)
	:= (others => INIT_OUT);

    attribute REGISTER_BALANCING of shift : signal is "NO";
    attribute REGISTER_DUPLICATION of shift : signal is "NO";
    attribute ASYNC_REG of shift : signal is "TRUE";
    attribute IOB of shift : signal is "FALSE";

begin

    sync_proc : process (clk, async_in)
    begin

	if rising_edge(clk) then
	    shift <= shift(STAGES - 1 downto 1) & async_in;
	end if;

    end process;

    sync_out <= shift(STAGES);

end RTL;


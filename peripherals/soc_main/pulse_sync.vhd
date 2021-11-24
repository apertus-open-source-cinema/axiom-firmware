----------------------------------------------------------------------------
--  pulse_sync.vhd
--	Pulse Synchronizer (N-Flop)
--	Version 1.2
--
--  SPDX-FileCopyrightText: © 2013 Herbert Poetzl <herbert@13thfloor.at>
--  SPDX-License-Identifier: GPL-2.0-or-later
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes


entity pulse_sync is
    generic (
	ACTIVE_IN : std_logic := '1';
	ACTIVE_OUT : std_logic := '1';
	STAGES : natural := 2
    );
    port (
	clk : in std_logic;			-- Target Clock
	async_in : in std_logic;		-- Async Input
	sync_out : out std_logic		-- Sync Output
    );
end entity pulse_sync;


architecture RTL of pulse_sync is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal shift : std_logic_vector (STAGES downto 1)
	:= (others => not ACTIVE_IN);

    attribute REGISTER_BALANCING of shift : signal is "NO";
    attribute REGISTER_DUPLICATION of shift : signal is "NO";
    attribute ASYNC_REG of shift : signal is "TRUE";
    attribute IOB of shift : signal is "FALSE";

begin

    sync_proc : process (clk, async_in)
	variable out_v : std_logic := not ACTIVE_OUT;
	variable sync_v : std_logic := not ACTIVE_IN;
    begin

	if rising_edge(clk) then
	    if sync_v = not ACTIVE_IN and
		shift(STAGES) = ACTIVE_IN then
		out_v := ACTIVE_OUT;
	    else
		out_v := not ACTIVE_OUT;
	    end if;

	    sync_v := shift(STAGES);
	    shift <= shift(STAGES - 1 downto 1) & async_in;
	end if;

	sync_out <= out_v;

    end process;

end RTL;


----------------------------------------------------------------------------
--  sync_delay.vhd
--	N-Stage Synchronous Delay
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

use work.vivado_pkg.ALL;	-- Vivado Attributes


entity sync_delay is
    generic (
	STAGES : natural := 2;
	DATA_WIDTH : natural := 1;
	INIT_OUT : std_logic := '0'
    );
    port (
	clk : in std_logic;
	data_in : in std_logic_vector (DATA_WIDTH - 1 downto 0);
	data_out : out std_logic_vector (DATA_WIDTH - 1 downto 0)
    );

end entity sync_delay;


architecture RTL of sync_delay is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    type delay_t is array (natural range <>) of
	std_logic_vector (DATA_WIDTH - 1 downto 0);

    signal shift : delay_t (STAGES downto 1)
	:= (others => (others => INIT_OUT));

    attribute REGISTER_BALANCING of shift : signal is "NO";
    attribute REGISTER_DUPLICATION of shift : signal is "NO";
    attribute ASYNC_REG of shift : signal is "TRUE";
    attribute IOB of shift : signal is "FALSE";

begin

    delay_proc : process (clk, data_in)
	variable sync_v : std_logic_vector (DATA_WIDTH - 1 downto 0)
	    := (others => INIT_OUT);
    begin

	if rising_edge(clk) then
	    sync_v := shift(STAGES);
	    shift <= shift(STAGES - 1 downto 1) & data_in;
	end if;

	data_out <= sync_v;

    end process;

end RTL;


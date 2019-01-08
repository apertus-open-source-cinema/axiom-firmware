----------------------------------------------------------------------------
--  pp_sync.vhd
--	Ping Pong Synchronizer
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


entity pp_sync is
    generic (
	STAGES : natural := 2
    );
    port (
	clk_a : in std_logic;
	ping_a : in std_logic;
	pong_a : out std_logic;
	active : out std_logic;
	--
	clk_b : in std_logic;
	pong_b : in std_logic;
	ping_b : out std_logic;
	action : out std_logic
    );
end entity pp_sync;


architecture RTL of pp_sync is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal ping : std_logic;
    signal pong : std_logic;

begin

    SYNC_ping_inst : entity work.data_sync
    generic map (
	STAGES => STAGES )
    port map (
	clk => clk_b,
	async_in => ping_a,
	sync_out => ping );

    SYNC_pong_inst : entity work.data_sync
    generic map (
	STAGES => STAGES )
    port map (
	clk => clk_a,
	async_in => pong_b,
	sync_out => pong );

    active <= ping_a xor pong;
    pong_a <= pong;

    action <= pong_b xor ping;
    ping_b <= ping;

end RTL;

----------------------------------------------------------------------------
--  pp_reg_sync.vhd
--	Ping Pong Register Synchronizer
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


entity pp_reg_sync is
    generic (
	AB_WIDTH : natural := 4;
	BA_WIDTH : natural := 4;
	STAGES : natural := 2
    );
    port (
	clk_a : in std_logic;
	ping_a : in std_logic;
	pong_a : out std_logic;
	active : out std_logic;
	--
	reg_ab_in : in std_logic_vector (AB_WIDTH - 1 downto 0);
	reg_ba_out : out std_logic_vector (BA_WIDTH - 1 downto 0);
	--
	clk_b : in std_logic;
	pong_b : in std_logic;
	ping_b : out std_logic;
	action : out std_logic;
	--
	reg_ba_in : in std_logic_vector (BA_WIDTH - 1 downto 0);
	reg_ab_out : out std_logic_vector (AB_WIDTH - 1 downto 0)
    );
end entity pp_reg_sync;


architecture RTL of pp_reg_sync is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

	-- clk_a domain
    signal ping_a_d : std_logic;
    signal pong, pong_d : std_logic;

	-- clk_b domain
    signal ping, ping_d : std_logic;
    signal pong_b_d : std_logic;

	-- mixed domain
    signal reg_ab : std_logic_vector (AB_WIDTH - 1 downto 0);
    signal reg_ba : std_logic_vector (BA_WIDTH - 1 downto 0);

    attribute ASYNC_REG of reg_ab : signal is "TRUE";
    attribute ASYNC_REG of reg_ba : signal is "TRUE";

begin

    SYNC_ping_inst : entity work.data_sync
    generic map (
	STAGES => STAGES )
    port map (
	clk => clk_b,
	async_in => ping_a_d,	-- clk_a domain
	sync_out => ping );

    SYNC_pong_inst : entity work.data_sync
    generic map (
	STAGES => STAGES )
    port map (
	clk => clk_a,
	async_in => pong_b_d,	-- clk_b domain
	sync_out => pong );

    reg_ab_in_proc : process (clk_a, ping_a, reg_ab_in)
    begin
	if rising_edge(clk_a) then
	    if ping_a /= ping_a_d then
		reg_ab <= reg_ab_in;
	    end if;
	    ping_a_d <= ping_a;

	    if pong /= pong_d then
		reg_ba_out <= reg_ba;
	    end if;
	    pong_d <= pong;
	end if;
    end process;

    active <= ping_a xor pong_d;
    pong_a <= pong_d;

    reg_ba_in_proc : process (clk_b, pong_b, reg_ba_in)
    begin
	if rising_edge(clk_b) then
	    if pong_b /= pong_b_d then
		reg_ba <= reg_ba_in;
	    end if;
	    pong_b_d <= pong_b;

	    if ping /= ping_d then
		reg_ab_out <= reg_ab;
	    end if;
	    ping_d <= ping;
	end if;
    end process;

    action <= pong_b xor ping_d;
    ping_b <= ping_d;

end RTL;

----------------------------------------------------------------------------
--  sync_div.vhd
--	Synchronous Divider
--	Version 1.0
--
--  SPDX-FileCopyrightText: © 2013 Herbert Poetzl <herbert@13thfloor.at>
--  SPDX-License-Identifier: GPL-2.0-or-later
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;

entity sync_div is
    generic (
	HRATIO : integer := 10000000
    );
    port (
	clk_in	: in std_logic;		-- input clock
	--
	clk_out : out std_logic		-- output clock
    );

    attribute BUFFER_TYPE : string;	-- buffer type

    attribute BUFFER_TYPE of clk_out : signal is "BUFG";

end entity sync_div;


architecture RTL of sync_div is
begin

    divide_proc : process (clk_in)

	variable count : natural range 0 to HRATIO - 1;

	variable clk_out_v : std_logic := '0';

    begin

	if rising_edge(clk_in) then	-- clk
	    if count = HRATIO - 1 then
		count := 0;
		clk_out_v := not clk_out_v;
	    else
		count := count + 1;
	    end if;
	end if;
	
	clk_out <= clk_out_v;

    end process;

end RTL;

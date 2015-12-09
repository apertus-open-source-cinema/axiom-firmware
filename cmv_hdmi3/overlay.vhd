----------------------------------------------------------------------------
--  overlay.vhd
--	Simple Overlay
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


entity overlay is
    port (
	clk	: in std_logic;
	enable	: in std_logic;
	--
	ctrl	: in std_logic_vector (15 downto 0);
	din	: in std_logic_vector (63 downto 0);
	--
	dout	: out std_logic_vector (63 downto 0)
    );
end entity overlay;


architecture RTL of overlay is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

begin

    overlay_proc : process (clk)
    begin
	if rising_edge(clk) then
	    if enable = '1' then
		case ctrl(15 downto 14) is
		    when "11" =>
			dout <= (
			    63 => ctrl(11), 62 => ctrl(10), 61 => ctrl(9),
			    47 => ctrl(8), 46 => ctrl(7), 45 => ctrl(6),
			    31 => ctrl(5), 30 => ctrl(4), 29 => ctrl(3),
			    15 => ctrl(2), 14 => ctrl(1), 13 => ctrl(0),
			    others => '0' );

		    when "10" =>
			dout <= "0" & din(63 downto 49) &
				"0" & din(47 downto 33) &
				"0" & din(31 downto 17) &
				"0" & din(15 downto 1);

		    when "01" =>
			dout <= "00" & din(63 downto 50) &
				"00" & din(47 downto 34) &
				"00" & din(31 downto 18) &
				"00" & din(15 downto 2);

		    when others =>
			dout <= din;

		end case;
	    else
		dout <= din;
	    end if;
	end if;
    end process;

end RTL;

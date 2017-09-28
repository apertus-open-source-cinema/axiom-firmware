----------------------------------------------------------------------------
--  enc_ctrl.vhd
--	Encode TMDS Bitstream
--	Version 1.0
--
--  Copyright (C) 2014-2015 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes

entity enc_ctrl is
    port (
	clk	: in std_logic;
	--
	cin	: in std_logic_vector (1 downto 0);
	--
	dout	: out std_logic_vector (9 downto 0)
    );
end entity enc_ctrl;


architecture RTL of enc_ctrl is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

begin

    enc_proc: process(clk)
    begin
	if rising_edge(clk) then
	    case cin is
	       when "00"   => dout <= "1101010100";
	       when "01"   => dout <= "0010101011";
	       when "10"   => dout <= "0101010100";
	       when "11"   => dout <= "1010101011";
	       when others => dout <= "0000000000";
	    end case;
	end if;
    end process;

end RTL;


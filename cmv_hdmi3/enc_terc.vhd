----------------------------------------------------------------------------
--  enc_terc.vhd
--	Encode TERC4 Data
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

entity enc_terc is
    port (
	clk	: in std_logic;
	--
	din	: in std_logic_vector (3 downto 0);
	--
	dout	: out std_logic_vector (9 downto 0)
    );
end entity enc_terc;


architecture RTL of enc_terc is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

begin

    enc_proc: process(clk)
    begin
	if rising_edge(clk) then
	    case din is
	       when "0000" => dout <= "1010011100";
	       when "0001" => dout <= "1001100011";
	       when "0010" => dout <= "1011100100";
	       when "0011" => dout <= "1011100010";
	       when "0100" => dout <= "0101110001";
	       when "0101" => dout <= "0100011110";
	       when "0110" => dout <= "0110001110";
	       when "0111" => dout <= "0100111100";
	       when "1000" => dout <= "1011001100";
	       when "1001" => dout <= "0100111001";
	       when "1010" => dout <= "0110011100";
	       when "1011" => dout <= "1011000110";
	       when "1100" => dout <= "1010001110";
	       when "1101" => dout <= "1001110001";
	       when "1110" => dout <= "0101100011";
	       when "1111" => dout <= "1011000011";
	       when others => dout <= "0000000000";
	    end case;
	end if;
    end process;

end RTL;


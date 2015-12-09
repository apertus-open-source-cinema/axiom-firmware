----------------------------------------------------------------------------
--  remap_4x4.vhd
--	Remap 4x4 Inputs to 4x4 Outputs
--	Version 1.1
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


entity remap_4x4 is
    port (
	clk	: in std_logic;
	code	: in std_logic_vector(7 downto 0);
	--
	din	: in std_logic_vector(15 downto 0);
	--
	dout	: out std_logic_vector(15 downto 0)
    );
end entity remap_4x4;


architecture RTL of remap_4x4 is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

begin

    GEN_REMAP : for I in 0 to 3 generate
    begin
	dout(I * 4 + 3 downto I * 4) <=
	    din(to_integer(
		unsigned(code(I * 2 + 1 downto I * 2))) * 4 + 3
		downto to_integer(
		unsigned(code(I * 2 + 1 downto I * 2))) * 4);
    end generate;

end RTL;


architecture RTL_REG of remap_4x4 is

    attribute KEEP_HIERARCHY of RTL_REG : architecture is "TRUE";

begin

    remap_proc : process (clk)
	variable code_v : natural;
    begin
	if rising_edge(clk) then
	    for I in 0 to 3 loop
		code_v := to_integer(
		    unsigned(code(I * 2 + 1 downto I * 2)));
		dout(I * 4 + 3 downto I * 4) <=
		    din(code_v * 4 + 3 downto code_v * 4);
	    end loop;
	end if;
    end process;

end RTL_REG;

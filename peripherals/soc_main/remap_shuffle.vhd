----------------------------------------------------------------------------
--  remap_shuffle.vhd
--	Remap 4x4x4 Inputs to 4x4x4 Outputs
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


entity remap_shuffle is
    port (
	clk	: in std_logic;
	code0	: in std_logic_vector(31 downto 0);
	code1	: in std_logic_vector(31 downto 0);
	code2	: in std_logic_vector(31 downto 0);
	--
	din	: in std_logic_vector(63 downto 0);
	--
	dout	: out std_logic_vector(63 downto 0)
    );
end entity remap_shuffle;


architecture RTL of remap_shuffle is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal map0_out : std_logic_vector(63 downto 0);
    signal map1_in : std_logic_vector(63 downto 0);
    signal map1_out : std_logic_vector(63 downto 0);
    signal map2_in : std_logic_vector(63 downto 0);

begin

    GEN_4x4_C0: for I in 3 downto 0 generate
    begin
	remap_inst : entity work.remap_4x4 (RTL_REG)
	    port map (
		clk => clk,
		code => code0(I * 8 + 7 downto I * 8),
		din => din(I * 16 + 15 downto I * 16),
		dout => map0_out(I * 16 + 15 downto I * 16) );

	map1_in(I * 16 + 15 downto I * 16) <=
	    map0_out(I * 4 + 48 + 3 downto I * 4 + 48) & 
	    map0_out(I * 4 + 32 + 3 downto I * 4 + 32) &
	    map0_out(I * 4 + 16 + 3 downto I * 4 + 16) &
	    map0_out(I * 4 + 3 downto I * 4);

    end generate;

    GEN_4x4_C1: for I in 3 downto 0 generate
    begin
	remap_inst : entity work.remap_4x4 (RTL_REG)
	    port map (
		clk => clk,
		code => code1(I * 8 + 7 downto I * 8),
		din => map1_in(I * 16 + 15 downto I * 16),
		dout => map1_out(I * 16 + 15 downto I * 16) );

	map2_in(I * 16 + 15 downto I * 16) <=
	    map1_out(I * 4 + 48 + 3 downto I * 4 + 48) & 
	    map1_out(I * 4 + 32 + 3 downto I * 4 + 32) &
	    map1_out(I * 4 + 16 + 3 downto I * 4 + 16) &
	    map1_out(I * 4 + 3 downto I * 4);

    end generate;

    GEN_4x4_C2: for I in 3 downto 0 generate
    begin
	remap_inst : entity work.remap_4x4 (RTL_REG)
	    port map (
		clk => clk,
		code => code2(I * 8 + 7 downto I * 8),
		din => map2_in(I * 16 + 15 downto I * 16),
		dout => dout(I * 16 + 15 downto I * 16) );

    end generate;

end RTL;

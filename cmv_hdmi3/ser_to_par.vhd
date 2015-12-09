----------------------------------------------------------------------------
--  ser_to_par.vhd (for cmv_io2)
--	N-Channel Deserializer Unit
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

package par_array_pkg is

    type par8_a is array (natural range <>) of
	std_logic_vector (7 downto 0);

    type par10_a is array (natural range <>) of
	std_logic_vector (9 downto 0);

    type par12_a is array (natural range <>) of
	std_logic_vector (11 downto 0);

    type par16_a is array (natural range <>) of
	std_logic_vector (15 downto 0);

end par_array_pkg;


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

library unimacro;
use unimacro.VCOMPONENTS.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.par_array_pkg.ALL;	-- Parallel Data


entity ser_to_par is
    generic (
	CHANNELS : natural := 32
    );
    port (
	serdes_clk	: in  std_logic;
	serdes_clkdiv	: in  std_logic;
	serdes_phase	: in  std_logic;
	serdes_rst	: in  std_logic;
	--
	ser_data	: in  std_logic_vector (CHANNELS - 1 downto 0);
	--
	par_clk		: in  std_logic;
	par_enable	: out  std_logic;
	par_data	: out par12_a (CHANNELS - 1 downto 0);
	--
	bitslip		: in  std_logic_vector (CHANNELS - 1 downto 0)
    );

end entity ser_to_par;


architecture RTL of ser_to_par is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

begin

    GEN_serdes : for I in CHANNELS - 1 downto 0 generate
	serdes_inst : entity work.cmv_serdes
	    port map (
		serdes_clk    => serdes_clk,
		serdes_clkdiv => serdes_clkdiv,
		serdes_phase  => serdes_phase,
		serdes_rst    => serdes_rst,
		--
		ser_data      => ser_data(I),
		par_data      => par_data(I),
		--
		bitslip       => bitslip(I) );

    end generate;

    push_proc : process (par_clk)
	variable phase_d_v : std_logic;
    begin
	if rising_edge(par_clk) then
	    if phase_d_v = '1' and serdes_phase = '0' then
		par_enable <= '1';
	    else
		par_enable <= '0';
	    end if;

	    phase_d_v := serdes_phase;
	end if;
    end process;

end RTL;

----------------------------------------------------------------------------
--  cfg_lut5.vhd
--	CFGLUT5 Reconfiguration
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes


entity cfg_lut5 is
    port (
	lut_clk_in : in std_logic;
	--
	lut_action : in std_logic;
	lut_active : out std_logic;
	--
	lut_write : in std_logic;
	lut_din : in std_logic_vector (31 downto 0);
	--
	lut_dout : out std_logic_vector (31 downto 0);
	lut_latch : out std_logic;
	--
	lut_clk : out std_logic;
	lut_en : out std_logic;
	lut_cdi : out std_logic;
	lut_cdo : in std_logic
    );
end entity cfg_lut5;


architecture RTL of cfg_lut5 is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal enable : std_logic := '0';
    signal enable_shift : std_logic;

    signal data_shift : std_logic_vector (31 downto 0)
	:= (others => '0');

    signal ctrl_shift : std_logic_vector (33 downto 0)
	:= (others => '0');

begin

    --------------------------------------------------------------------
    -- CFGLUT5 Sequence
    --------------------------------------------------------------------

    ctrl_proc : process (lut_clk_in)
    begin
	if rising_edge(lut_clk_in) then
	    ctrl_shift <= lut_action & 
		ctrl_shift(ctrl_shift'high downto 1);
	end if;
    end process;

    enable_proc : process (lut_clk_in)
    begin
	if rising_edge(lut_clk_in) then
	    if lut_action = '1' then
		enable <= '1'; 
	    elsif ctrl_shift(0) = '1' then
		enable <= '0';
	    end if;
	end if;
    end process;

    enable_shift <= enable and not ctrl_shift(0) and
	not ctrl_shift(ctrl_shift'high);

    lut_en <= enable_shift;
    lut_clk <= lut_clk_in when enable_shift = '1' else '0';

    --------------------------------------------------------------------
    -- CFGLUT5 Data Shift
    --------------------------------------------------------------------

    data_in_proc : process (
	lut_clk_in, lut_action,
	lut_din, lut_cdo )
    begin
	if rising_edge(lut_clk_in) then
	    if lut_action = '1' then			-- sync load
		data_shift(31 downto 0) <= lut_din;

	    elsif enable_shift = '1' then		-- shift in
		data_shift <=
		    data_shift(data_shift'high - 1 downto 0)
		    & lut_cdo;

	    end if;
	end if;
    end process;

    lut_cdi <= data_shift(data_shift'high)
	when lut_write = '1' else lut_cdo;

    lut_dout <= data_shift(lut_dout'high downto 0);
    lut_latch <= ctrl_shift(0);
    lut_active <= enable;

end RTL;

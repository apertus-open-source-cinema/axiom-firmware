----------------------------------------------------------------------------
--  cmv_spi.vhd
--	CMV12K SPI Interface
--	Version 1.1
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


entity cmv_spi is
    port (
	spi_clk_in : in std_logic;
	--
	spi_action : in std_logic;
	spi_active : out std_logic;
	--
	spi_write : in std_logic;
	spi_addr : in std_logic_vector (6 downto 0);
	spi_din : in std_logic_vector (15 downto 0);
	--
	spi_dout : out std_logic_vector (15 downto 0);
	spi_latch : out std_logic;
	--
	spi_clk : out std_logic;
	spi_en : out std_logic;
	spi_in : out std_logic;
	spi_out : in std_logic
    );
end entity cmv_spi;


architecture RTL of cmv_spi is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal enable_a : std_logic := '0';
    signal enable_b : std_logic := '0';
    signal enable : std_logic := '0';

    signal data_shift : std_logic_vector (22 downto 0)
	:= (others => '0');

    signal ctrl_shift : std_logic_vector (24 downto 0)
	:= (others => '0');

begin

    --------------------------------------------------------------------
    -- CMV SPI Sequence
    --------------------------------------------------------------------

    ctrl_proc : process (spi_clk_in)
    begin
	if falling_edge(spi_clk_in) then
	    ctrl_shift <= spi_action & 
		ctrl_shift(ctrl_shift'high downto 1);
	end if;
    end process;

    --------------------------------------------------------------------
    -- CMV SPI Enable Signal
    --------------------------------------------------------------------

    enable_a_proc : process (spi_clk_in, spi_action)
    begin
	if falling_edge(spi_clk_in) then
	    if spi_action = '1' then
		enable_a <= not enable_b;
	    end if;
	end if;
    end process;

    enable_b_proc : process (spi_clk_in, ctrl_shift(0))
    begin
	if rising_edge(spi_clk_in) then
	    if ctrl_shift(0) = '1' then
		enable_b <= enable_a;
	    end if;
	end if;
    end process;

    enable <= enable_a xor enable_b;
    spi_en <= enable;
    spi_clk <= spi_clk_in when enable = '1' else '0';
    -- spi_clk <= spi_clk_in when enable = '1' and spi_action = '0' else '0';

    --------------------------------------------------------------------
    -- CMV SPI Data Shift
    --------------------------------------------------------------------

    data_in_proc : process (
	spi_clk_in, spi_action,
	spi_din, spi_addr, spi_out)
    begin
	if rising_edge(spi_clk_in) then
	    if spi_action = '1' then			-- sync load
		data_shift(15 downto 0) <= spi_din;
		data_shift(22 downto 16) <= spi_addr;
		-- data_shift(23) <= spi_write;

	    elsif enable = '1' then			-- shift in
		data_shift <=
		    data_shift(data_shift'high - 1 downto 0)
		    & spi_out;

	    end if;
	end if;
    end process;

    data_out_proc : process (spi_clk_in, spi_action)
    begin
	if falling_edge(spi_clk_in) then
	    if spi_action = '1' then			-- sync load
		spi_in <= spi_write;
	    else
		spi_in <= data_shift(data_shift'high);
	    end if;
	end if;
    end process;

    spi_dout <= data_shift(spi_dout'high + 1 downto 1);
    spi_latch <= ctrl_shift(0) and not spi_action;

    --------------------------------------------------------------------
    -- CMV SPI Active Signal
    --------------------------------------------------------------------

    active_proc : process (
	spi_clk_in, spi_action, enable)
    begin
	if rising_edge(spi_clk_in) then
	    if spi_action = '1' then
		spi_active <= '1';
	    elsif enable = '0' then
		spi_active <= '0';
	    end if;
	end if;
    end process;

end RTL;

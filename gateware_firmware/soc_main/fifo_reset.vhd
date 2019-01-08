----------------------------------------------------------------------------
--  fifo_reset.vhd
--	FIFO Reset Manager (dual domain)
--	Version 1.3
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



entity fifo_reset is
    generic (
	CYCLES_PRE : natural := 4;
	CYCLES_RST : natural := 5;
	CYCLES_POST : natural := 2 );
    port (
	rclk	: in std_logic;
	wclk	: in std_logic;
	reset	: in std_logic;
	--
	fifo_rst : out std_logic;
	fifo_rrdy : out std_logic;
	fifo_wrdy : out std_logic );

end entity fifo_reset;


architecture RTL of fifo_reset is

    constant SHIFT_SIZE : natural
	:= CYCLES_PRE + CYCLES_RST + CYCLES_POST;
    constant INDEX_PRE : natural
	:= CYCLES_RST + CYCLES_POST;
    constant INDEX_RST : natural
	:= CYCLES_POST;

	-- rclk domain
    signal r_prep_rclk : std_logic;
    signal r_hold_rclk : std_logic;
    signal r_post_rclk : std_logic;

    signal w_prep_rclk : std_logic;
    signal w_hold_rclk : std_logic;
    signal w_post_rclk : std_logic;

	-- wclk domain
    signal r_prep_wclk : std_logic;
    signal r_hold_wclk : std_logic;
    signal r_post_wclk : std_logic;

    signal w_prep_wclk : std_logic;
    signal w_hold_wclk : std_logic;
    signal w_post_wclk : std_logic;

begin

    sync_rclk_proc : process (rclk, reset)
	variable shift_prep_v : std_logic_vector (2 downto 0)
	    := (others => '0');
	variable shift_hold_v : std_logic_vector (2 downto 0)
	    := (others => '0');
	variable shift_post_v : std_logic_vector (2 downto 0)
	    := (others => '0');

	attribute ASYNC_REG of shift_prep_v : variable is "TRUE";
	attribute ASYNC_REG of shift_hold_v : variable is "TRUE";
	attribute ASYNC_REG of shift_post_v : variable is "TRUE";

    begin
	if reset = '1' then
	    shift_prep_v := (others => '0');
	    shift_hold_v := (others => '0');
	    shift_post_v := (others => '0');

	elsif rising_edge(rclk) then
	    shift_prep_v := w_prep_wclk &
		shift_prep_v(shift_prep_v'high downto 1);
	    shift_hold_v := w_hold_wclk &
		shift_hold_v(shift_hold_v'high downto 1);
	    shift_post_v := w_post_wclk &
		shift_post_v(shift_post_v'high downto 1);
	end if;
	
	w_prep_rclk <= shift_prep_v(0);
	w_hold_rclk <= shift_hold_v(0);
	w_post_rclk <= shift_post_v(0);
    end process;


    sync_wclk_proc : process (wclk, reset)
	variable shift_prep_v : std_logic_vector (2 downto 0)
	    := (others => '0');
	variable shift_hold_v : std_logic_vector (2 downto 0)
	    := (others => '0');
	variable shift_post_v : std_logic_vector (2 downto 0)
	    := (others => '0');

	attribute ASYNC_REG of shift_prep_v : variable is "TRUE";
	attribute ASYNC_REG of shift_hold_v : variable is "TRUE";
	attribute ASYNC_REG of shift_post_v : variable is "TRUE";

    begin
	if reset = '1' then
	    shift_prep_v := (others => '0');
	    shift_hold_v := (others => '0');
	    shift_post_v := (others => '0');

	elsif rising_edge(wclk) then
	    shift_prep_v := r_prep_rclk &
		shift_prep_v(shift_prep_v'high downto 1);
	    shift_hold_v := r_hold_rclk &
		shift_hold_v(shift_hold_v'high downto 1);
	    shift_post_v := r_post_rclk &
		shift_post_v(shift_post_v'high downto 1);
	end if;
	
	r_prep_wclk <= shift_prep_v(0);
	r_hold_wclk <= shift_hold_v(0);
	r_post_wclk <= shift_post_v(0);
    end process;


    rst_rclk_proc : process (rclk)
	variable shift_v : std_logic_vector (SHIFT_SIZE - 1 downto 0)
	    := (others => '0');
    begin
	if reset = '1' then
	    shift_v := (others => '0');

	elsif rising_edge(rclk) then
	    if shift_v(INDEX_PRE) = '0' then
		shift_v := '1' & shift_v(shift_v'high downto 1);
	    elsif shift_v(INDEX_RST) = '0' then
		if w_prep_rclk = '1' then
		    shift_v := '1' & shift_v(shift_v'high downto 1);
		end if;
	    elsif shift_v(0) = '0' then
		if w_hold_rclk = '1' then
		    shift_v := '1' & shift_v(shift_v'high downto 1);
		end if;
	    end if;
	end if;
	
	r_prep_rclk <= shift_v(INDEX_PRE);
	r_hold_rclk <= shift_v(INDEX_RST);
	r_post_rclk <= shift_v(0);
    end process;

    fifo_rrdy <= r_post_rclk and w_post_rclk;
    fifo_rst <= (r_hold_rclk xor r_prep_rclk) and (w_hold_rclk xor w_prep_rclk);

    rst_wclk_proc : process (wclk)
	variable shift_v : std_logic_vector (SHIFT_SIZE - 1 downto 0)
	    := (others => '0');
    begin
	if reset = '1' then
	    shift_v := (others => '0');

	elsif rising_edge(wclk) then
	    if shift_v(INDEX_PRE) = '0' then
		shift_v := '1' & shift_v(shift_v'high downto 1);
	    elsif shift_v(INDEX_RST) = '0' then
		if r_prep_wclk = '1' then
		    shift_v := '1' & shift_v(shift_v'high downto 1);
		end if;
	    elsif shift_v(0) = '0' then
		if r_hold_wclk = '1' then
		    shift_v := '1' & shift_v(shift_v'high downto 1);
		end if;
	    end if;
	end if;

	w_prep_wclk <= shift_v(INDEX_PRE);
	w_hold_wclk <= shift_v(INDEX_RST);
	w_post_wclk <= shift_v(0);
    end process;

    fifo_wrdy <= r_post_wclk and w_post_wclk;

end RTL;

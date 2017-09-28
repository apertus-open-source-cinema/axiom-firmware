----------------------------------------------------------------------------
--  scan_event.vhd
--	Scan Generator Event Combiner
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

entity scan_event is
    port (
	clk	: in std_logic;				-- Scan CLK
	reset_n	: in std_logic;				-- # Reset
	--
	disp_in	: in std_logic_vector(3 downto 0);
	sync_in	: in std_logic_vector(3 downto 0);
	data_in	: in std_logic_vector(3 downto 0);
	ctrl_in	: in std_logic_vector(3 downto 0);
	--
	hevent	: in std_logic_vector(3 downto 0);
	vevent	: in std_logic_vector(3 downto 0);
	--
	hcnt_in	: in std_logic_vector(11 downto 0);
	vcnt_in	: in std_logic_vector(11 downto 0);
	fcnt_in	: in std_logic_vector(11 downto 0);
	--
	data_eo	: in std_logic;
	econf	: in std_logic_vector(63 downto 0);
	--
	hsync	: out std_logic;
	vsync	: out std_logic;
	pream	: out std_logic_vector(1 downto 0);
	guard	: out std_logic_vector(2 downto 0);
	data	: out std_logic_vector(1 downto 0);
	disp	: out std_logic;
	terc	: out std_logic;
	--
	event	: out std_logic_vector(7 downto 0);
	--
	hcnt	: out std_logic_vector(11 downto 0);
	vcnt	: out std_logic_vector(11 downto 0);
	fcnt	: out std_logic_vector(11 downto 0)
    );
end entity scan_event;


architecture RTL of scan_event is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

begin

    sync_proc : process (clk)
    begin
	if rising_edge(clk) then
	    hsync <= sync_in(0) xor sync_in(1);
	    vsync <= sync_in(2) xor sync_in(3);
	end if;
    end process;

    disp_proc : process (clk)
    begin
	if rising_edge(clk) then
	    disp <= 
		(disp_in(0) xor disp_in(1)) and
		(disp_in(2) xor disp_in(3));
	end if;
    end process;

    data_proc : process (clk)
    begin
	if rising_edge(clk) then
	    data(0) <= 
		(data_in(0) xor data_in(1)) and
		(data_in(2) xor data_in(3));
	    data(1) <= data_eo xor hcnt_in(0);
	end if;
    end process;

    pream_proc : process (clk)
    begin
	if rising_edge(clk) then
	    pream(0) <= 
		(ctrl_in(0) xor ctrl_in(1)) and
		(disp_in(2) xor disp_in(3));
	    pream(1) <= 
		(ctrl_in(0) xor ctrl_in(1)) and
		(sync_in(2) xor sync_in(3));
	end if;
    end process;

    guard_proc : process (clk)
    begin
	if rising_edge(clk) then
	    guard(0) <= 
		(ctrl_in(1) xor disp_in(0)) and
		(disp_in(2) xor disp_in(3));
	    guard(1) <= 
		(ctrl_in(1) xor disp_in(0)) and
		(sync_in(2) xor sync_in(3));
	    guard(2) <= 
		(ctrl_in(2) xor ctrl_in(3)) and
		(sync_in(2) xor sync_in(3));
	end if;
    end process;

    terc_proc : process (clk)
    begin
	if rising_edge(clk) then
	    terc <= 
		(disp_in(0) xor ctrl_in(2)) and
		(sync_in(2) xor sync_in(3));
	end if;
    end process;

    GEN_EVENT: for I in event'range generate
	event_proc : process (clk)
	    alias hs_i : std_logic_vector(1 downto 0)
		is econf(I * 8 + 7 downto I * 8 + 6);
	    alias he_i : std_logic_vector(1 downto 0)
		is econf(I * 8 + 5 downto I * 8 + 4);
	    alias vs_i : std_logic_vector(1 downto 0)
		is econf(I * 8 + 3 downto I * 8 + 2);
	    alias ve_i : std_logic_vector(1 downto 0)
		is econf(I * 8 + 1 downto I * 8 + 0);

	    variable hs_v : std_logic;
	    variable he_v : std_logic;
	    variable vs_v : std_logic;
	    variable ve_v : std_logic;

	    type ev_state is (
		idle_s, init_s, work_s, exit_s, wait_s );

	    variable state_v : ev_state := idle_s;
	    variable event_v : std_logic := '0';

	begin
	    if rising_edge(clk) then
		case hs_i is
		    when "00" => hs_v := '1';
		    when "01" => hs_v := hevent(0);
		    when "10" => hs_v := hevent(1);
		    when "11" => hs_v := hevent(2);
		end case;

		case he_i is
		    when "00" => he_v := hevent(0);
		    when "01" => he_v := hevent(1);
		    when "10" => he_v := hevent(2);
		    when "11" => he_v := hevent(3);
		end case;

		case vs_i is
		    when "00" => vs_v := vevent(0);
		    when "01" => vs_v := vevent(1);
		    when "10" => vs_v := vevent(2);
		    when "11" => vs_v := vevent(3);
		end case;

		case ve_i is
		    when "00" => ve_v := vevent(0);
		    when "01" => ve_v := vevent(1);
		    when "10" => ve_v := vevent(2);
		    when "11" => ve_v := vevent(3);
		end case;

		case state_v is
		    when idle_s =>
			if vs_v = '1' then
			    state_v := init_s;
			elsif ve_v = '1' then
			    state_v := wait_s;
			end if;

		    when init_s =>
			if hs_v = '1' then
			    event_v := '1';
			    state_v := work_s;
			end if;

		    when work_s =>
			if ve_v = '1' then
			    state_v := exit_s;
			end if;

		    when exit_s =>
			if he_v = '1' then
			    event_v := '0';
			    state_v := wait_s;
			end if;

		    when wait_s =>
			if ve_v = '0' then
			    state_v := idle_s;
			end if;
		end case;

		event(I) <= event_v;
	    end if;
	end process;
    end generate;

    cnt_proc : process (clk)
    begin
	if rising_edge(clk) then
	    hcnt <= hcnt_in;
	    vcnt <= vcnt_in;
	    fcnt <= fcnt_in;
	end if;
    end process;

end RTL;

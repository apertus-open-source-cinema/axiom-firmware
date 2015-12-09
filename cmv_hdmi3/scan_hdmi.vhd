----------------------------------------------------------------------------
--  scan_hdmi.vhd
--	Scan Generator for HDMI
--	Version 1.2
--
--  Copyright (C) 2013-2014 H.Poetzl
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


entity scan_hdmi is
    port (
	clk	: in std_logic;				-- Scan CLK
	reset_n	: in std_logic;				-- # Reset
	--
	total_w : in std_logic_vector(11 downto 0);	-- Total Width
	total_h : in std_logic_vector(11 downto 0);	-- Total Heigt
	total_f : in std_logic_vector(11 downto 0);	-- Total Frames
	--
	hdisp_s : in std_logic_vector(11 downto 0);
	hdisp_e : in std_logic_vector(11 downto 0);
	vdisp_s : in std_logic_vector(11 downto 0);
	vdisp_e : in std_logic_vector(11 downto 0);
	--
	hsync_s : in std_logic_vector(11 downto 0);
	hsync_e : in std_logic_vector(11 downto 0);
	vsync_s : in std_logic_vector(11 downto 0);
	vsync_e : in std_logic_vector(11 downto 0);
	--
	hdata_s : in std_logic_vector(11 downto 0);
	hdata_e : in std_logic_vector(11 downto 0);
	vdata_s : in std_logic_vector(11 downto 0);
	vdata_e : in std_logic_vector(11 downto 0);
	--
	event_0 : in std_logic_vector(11 downto 0);
	event_1 : in std_logic_vector(11 downto 0);
	event_2 : in std_logic_vector(11 downto 0);
	event_3 : in std_logic_vector(11 downto 0);
	--
	event_4 : in std_logic_vector(11 downto 0);
	event_5 : in std_logic_vector(11 downto 0);
	event_6 : in std_logic_vector(11 downto 0);
	event_7 : in std_logic_vector(11 downto 0);
	--
	pream_s : in std_logic_vector(11 downto 0);
	guard_s : in std_logic_vector(11 downto 0);
	terc4_e : in std_logic_vector(11 downto 0);
	guard_e : in std_logic_vector(11 downto 0);
	--
	disp	: out std_logic_vector(3 downto 0);
	sync	: out std_logic_vector(3 downto 0);
	data	: out std_logic_vector(3 downto 0);
	ctrl	: out std_logic_vector(3 downto 0);
	--
	hevent	: out std_logic_vector(3 downto 0);
	vevent	: out std_logic_vector(3 downto 0);
	--
	hcnt	: out std_logic_vector(11 downto 0);
	vcnt	: out std_logic_vector(11 downto 0);
	fcnt	: out std_logic_vector(11 downto 0)
    );
end entity scan_hdmi;


architecture RTL of scan_hdmi is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal cnt_h : unsigned(11 downto 0) := x"000";
    signal cnt_v : unsigned(11 downto 0) := x"000";
    signal cnt_f : unsigned(11 downto 0) := x"000";

    signal ab : std_logic_vector(47 downto 0);

    alias a : std_logic_vector(29 downto 0) is ab(47 downto 18);
    alias b : std_logic_vector(17 downto 0) is ab(17 downto 0);

    alias lim_h : std_logic_vector(11 downto 0) is ab(11 downto 0);
    alias lim_v : std_logic_vector(11 downto 0) is ab(23 downto 12);
    alias lim_f : std_logic_vector(11 downto 0) is ab(35 downto 24);
    alias lim_x : std_logic_vector(11 downto 0) is ab(47 downto 36);

    signal c : std_logic_vector(47 downto 0);

    alias c_cnt_h : std_logic_vector(11 downto 0) is c(11 downto 0);
    alias c_cnt_v : std_logic_vector(11 downto 0) is c(23 downto 12);
    alias c_cnt_f : std_logic_vector(11 downto 0) is c(35 downto 24);
    alias c_cnt_x : std_logic_vector(11 downto 0) is c(47 downto 36);

    signal carry : std_logic_vector(3 downto 0);

begin

    lim_h <= total_w;
    lim_v <= total_h;
    lim_f <= total_f;
    lim_x <= (others => '0');

    scan_proc : process (clk)
    begin
	if rising_edge(clk) then
	    if reset_n = '0' then
		cnt_h <= x"000";
		cnt_v <= x"000";
		cnt_f <= x"000";

	    elsif carry(0) = '1' then
		if carry(1) = '1' then
		    if carry(2) = '1' then
			cnt_f <= x"000";
		    else
			cnt_f <= cnt_f + "1";
		    end if;

		    cnt_v <= x"000";
		else
		    cnt_v <= cnt_v + "1";
		end if;

		cnt_h <= x"000";
	    else
		cnt_h <= cnt_h + "1";
	    end if;
	end if;
    end process;

    -- delay_proc : process(clk)
    -- begin
	-- if rising_edge(clk) then
	    hcnt <= std_logic_vector(cnt_h);
	    vcnt <= std_logic_vector(cnt_v);
	    fcnt <= std_logic_vector(cnt_f);
	-- end if;
    -- end process;

    c_cnt_h <= std_logic_vector(cnt_h);
    c_cnt_v <= std_logic_vector(cnt_v);
    c_cnt_f <= std_logic_vector(cnt_f);
    c_cnt_x <= (others => '0');

    DSP48E1_limit_inst : entity work.dsp48_wrap
	generic map (
	    USE_SIMD => "FOUR12" )	-- SIMD selection ("ONE48", "TWO24", "FOUR12")
	port map (
	    CLK => clk,			-- 1-bit input: Clock input
	    A => a,			-- 30-bit input: A data input
	    B => b,			-- 18-bit input: B data input
	    C => c,			-- 48-bit input: C data input
	    ALUMODE => "0001",		-- 4-bit input: ALU control input
	    OPMODE => "0111011",	-- 7-bit input: Operation mode input
	    --
	    CARRYOUT => carry );	-- 4-bit carry output

    scan_comp_inst0 : entity work.scan_comp
	port map (
	    clk => clk,
	    reset_n => reset_n,
	    --
	    a0 => hdisp_s,
	    a1 => hdisp_e,
	    a2 => vdisp_s,
	    a3 => vdisp_e,
	    --
	    b0 => std_logic_vector(cnt_h),
	    b1 => std_logic_vector(cnt_h),
	    b2 => std_logic_vector(cnt_v),
	    b3 => std_logic_vector(cnt_v),
	    --
	    flags => disp );

    scan_comp_inst1 : entity work.scan_comp
	port map (
	    clk => clk,
	    reset_n => reset_n,
	    --
	    a0 => hsync_s,
	    a1 => hsync_e,
	    a2 => vsync_s,
	    a3 => vsync_e,
	    --
	    b0 => std_logic_vector(cnt_h),
	    b1 => std_logic_vector(cnt_h),
	    b2 => std_logic_vector(cnt_v),
	    b3 => std_logic_vector(cnt_v),
	    --
	    flags => sync );

    scan_comp_inst2 : entity work.scan_comp
	port map (
	    clk => clk,
	    reset_n => reset_n,
	    --
	    a0 => hdata_s,
	    a1 => hdata_e,
	    a2 => vdata_s,
	    a3 => vdata_e,
	    --
	    b0 => std_logic_vector(cnt_h),
	    b1 => std_logic_vector(cnt_h),
	    b2 => std_logic_vector(cnt_v),
	    b3 => std_logic_vector(cnt_v),
	    --
	    flags => data );

    scan_comp_inst3 : entity work.scan_comp
	port map (
	    clk => clk,
	    reset_n => reset_n,
	    --
	    a0 => event_0,
	    a1 => event_1,
	    a2 => event_2,
	    a3 => event_3,
	    --
	    b0 => std_logic_vector(cnt_h),
	    b1 => std_logic_vector(cnt_h),
	    b2 => std_logic_vector(cnt_h),
	    b3 => std_logic_vector(cnt_h),
	    --
	    flags => hevent(3 downto 0) );

    scan_comp_inst4 : entity work.scan_comp
	port map (
	    clk => clk,
	    reset_n => reset_n,
	    --
	    a0 => event_4,
	    a1 => event_5,
	    a2 => event_6,
	    a3 => event_7,
	    --
	    b0 => std_logic_vector(cnt_v),
	    b1 => std_logic_vector(cnt_v),
	    b2 => std_logic_vector(cnt_v),
	    b3 => std_logic_vector(cnt_v),
	    --
	    flags => vevent(3 downto 0) );

    scan_comp_inst5 : entity work.scan_comp
	port map (
	    clk => clk,
	    reset_n => reset_n,
	    --
	    a0 => pream_s,
	    a1 => guard_s,
	    a2 => terc4_e,
	    a3 => guard_e,
	    --
	    b0 => std_logic_vector(cnt_h),
	    b1 => std_logic_vector(cnt_h),
	    b2 => std_logic_vector(cnt_h),
	    b3 => std_logic_vector(cnt_h),
	    --
	    flags => ctrl );
end RTL;

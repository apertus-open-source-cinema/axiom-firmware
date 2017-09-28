----------------------------------------------------------------------------
--  rgb_hdmi.vhd
--	Convert RGB + Event Data to HDMI
--	Version 1.0
--
--  Copyright (C) 2015 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.helper_pkg.ALL;	-- Vivado Attributes
use work.vec_mat_pkg.ALL;	-- Vector Types

entity rgb_hdmi is
    port (
	pix_clk	: in std_logic;
	bit_clk	: in std_logic;
	--
	enable	: in std_logic;
	reset	: in std_logic;
	--
	rgb	: in vec8_a (2 downto 0);
	data	: in std_logic_vector (8 downto 0);
	--
	de	: in std_logic_vector (1 downto 0);
	pream	: in std_logic_vector (1 downto 0);
	guard	: in std_logic_vector (2 downto 0);
	hsync	: in std_logic;
	vsync	: in std_logic;
	--
	d0idx	: in std_logic_vector (1 downto 0);
	d1idx	: in std_logic_vector (1 downto 0);
	d2idx	: in std_logic_vector (1 downto 0);
	clidx	: in std_logic_vector (1 downto 0);
	--
	d0inv	: in std_logic;
	d1inv	: in std_logic;
	d2inv	: in std_logic;
	clinv	: in std_logic;
	--
	tmds	: out std_logic_vector (3 downto 0)
    );
end entity rgb_hdmi;


architecture RTL of rgb_hdmi is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal bgr_data : vec8_a (2 downto 0) :=
	(others => (others => '0'));

    signal bgr_ctrl : vec2_a (2 downto 0) :=
	(others => (others => '0'));

    signal bgr_dilp : vec4_a (2 downto 0) :=
	(others => (others => '0'));

    signal guard_d : std_logic_vector (2 downto 0);
    signal guard_dd : std_logic_vector (2 downto 0);

    signal bgr_di : std_logic;
    signal bgr_di_d : std_logic;

    signal bgr_de : std_logic;
    signal bgr_de_d : std_logic;

    alias bgr_hsync : std_logic is bgr_ctrl(0)(0);
    alias bgr_vsync : std_logic is bgr_ctrl(0)(1);

    alias bgr_ctl0 : std_logic is bgr_ctrl(1)(0);
    alias bgr_ctl1 : std_logic is bgr_ctrl(1)(1);

    alias bgr_ctl2 : std_logic is bgr_ctrl(2)(0);
    alias bgr_ctl3 : std_logic is bgr_ctrl(2)(1);

    signal enc_tmds : vec10_a (3 downto 0);
    signal enc_terc : vec10_a (3 downto 0);
    signal enc_ctrl : vec10_a (3 downto 0);
    signal enc_data : vec10_a (3 downto 0);
    signal enc_sout : vec10_a (3 downto 0);

    signal slave_sout1 : std_logic_vector (3 downto 0);
    signal slave_sout2 : std_logic_vector (3 downto 0);

    signal enc_clk : std_logic;

    signal ser_clk : std_logic;
    signal ser_clk_div : std_logic;

    signal ser_enable : std_logic;
    signal ser_reset : std_logic;

    signal d0_index : natural;
    signal d1_index : natural;
    signal d2_index : natural;
    signal cl_index : natural;

begin

    reg_proc : process (enc_clk)
    begin
	if rising_edge(enc_clk) then
	    bgr_data(0) <= rgb(2);
	    bgr_data(1) <= rgb(1);
	    bgr_data(2) <= rgb(0);

	    bgr_hsync <= hsync;
	    bgr_vsync <= vsync;

	    bgr_ctl0 <= pream(0) or pream(1);
	    bgr_ctl1 <= '0';
	    bgr_ctl2 <= pream(1);
	    bgr_ctl3 <= '0';

	    bgr_de_d <= bgr_de;
	    bgr_de <= de(0);

	    bgr_dilp(0)(3) <= guard(1) or guard(2) or not guard_d(1);
	    bgr_dilp(0)(2) <= guard(1) or guard(2) or data(8);
	    bgr_dilp(0)(1) <= vsync;
	    bgr_dilp(0)(0) <= hsync;

	    bgr_dilp(1) <= data(7 downto 4);
	    bgr_dilp(2) <= data(3 downto 0);

	    bgr_di_d <= bgr_di;
	    bgr_di <= de(1);

	    guard_dd <= guard_d;
	    guard_d <= guard;
	end if;
    end process;

    ENC_GEN: for I in 2 downto 0 generate
	enc_ctrl_inst : entity work.enc_ctrl
	    port map (
		clk => enc_clk,
		cin => bgr_ctrl(I),
		dout => enc_ctrl(I) );

	enc_terc_inst : entity work.enc_terc
	    port map (
		clk => enc_clk,
		din => bgr_dilp(I),
		dout => enc_terc(I) );

	enc_tmds_inst : entity work.enc_tmds (RTL)
	    port map (
		clk => enc_clk,
		reset => not bgr_de,
		din => bgr_data(I),
		dout => enc_tmds(I) );
    end generate; 

    enc_clk <= pix_clk;

    enc_proc : process (enc_clk)
    begin
	if rising_edge(enc_clk) then
	    if bgr_de_d then
		enc_data(0) <= enc_tmds(0);
		enc_data(1) <= enc_tmds(1);
		enc_data(2) <= enc_tmds(2);

	    elsif guard_dd(0) then
		enc_data(0) <= "1011001100";
		enc_data(1) <= "0100110011";
		enc_data(2) <= "1011001100";

	    elsif bgr_di_d then
		enc_data(0) <= enc_terc(0);
		enc_data(1) <= enc_terc(1);
		enc_data(2) <= enc_terc(2);

	    elsif guard_dd(1) or guard_dd(2) then
		enc_data(0) <= enc_terc(0);
		enc_data(1) <= "0100110011";
		enc_data(2) <= "0100110011";

	    else
		enc_data(0) <= enc_ctrl(0);
		enc_data(1) <= enc_ctrl(1);
		enc_data(2) <= enc_ctrl(2);

	    end if;
	end if;
    end process;

    enc_data(3) <= "1111100000"; 

    d0_index <= to_index(d0idx xor "00");
    d1_index <= to_index(d1idx xor "01");
    d2_index <= to_index(d2idx xor "10");
    cl_index <= to_index(clidx xor "11");

    enc_sout(0) <= not enc_data(d0_index)
	when d0inv = '1' else enc_data(d0_index);

    enc_sout(1) <= not enc_data(d1_index)
	when d1inv = '1' else enc_data(d1_index);

    enc_sout(2) <= not enc_data(d2_index)
	when d2inv = '1' else enc_data(d2_index);

    enc_sout(3) <= not enc_data(cl_index)
	when clinv = '1' else enc_data(cl_index);

    OSERDES_GEN: for I in 3 downto 0 generate
	OSERDES_master_inst : entity work.oserdes_wrap
	    generic map (
		DATA_RATE_OQ => "DDR",		-- DDR, SDR
		DATA_WIDTH => 10,		-- Parallel data width (2-8,10,14)
		SERDES_MODE => "MASTER" )	-- MASTER, SLAVE
	    port map (
		CLK => ser_clk,			-- 1-bit input: High speed clock
		CLKDIV => ser_clk_div,		-- 1-bit input: Divided clock
		OCE => ser_enable,		-- 1-bit input: Output data clock enable
		RST => ser_reset,		-- 1-bit input: Reset
		D1 => enc_sout(I)(0),
		D2 => enc_sout(I)(1),
		D3 => enc_sout(I)(2),
		D4 => enc_sout(I)(3),
		D5 => enc_sout(I)(4),
		D6 => enc_sout(I)(5),
		D7 => enc_sout(I)(6),
		D8 => enc_sout(I)(7),
		OQ => tmds(I),			-- 1-bit output: Data path output
		SHIFTIN1 => slave_sout1(I),
		SHIFTIN2 => slave_sout2(I) );

	OSERDES_slave_inst : entity work.oserdes_wrap
	    generic map (
		DATA_RATE_OQ => "DDR",		-- DDR, SDR
		DATA_WIDTH => 10,		-- Parallel data width (2-8,10,14)
		SERDES_MODE => "SLAVE" )	-- MASTER, SLAVE
	    port map (
		CLK => ser_clk,			-- 1-bit input: High speed clock
		CLKDIV => ser_clk_div,		-- 1-bit input: Divided clock
		OCE => ser_enable,		-- 1-bit input: Output data clock enable
		RST => ser_reset,		-- 1-bit input: Reset
		D3 => enc_sout(I)(8),
		D4 => enc_sout(I)(9),
		SHIFTOUT1 => slave_sout1(I),
		SHIFTOUT2 => slave_sout2(I) );
    end generate;

    ser_clk <= bit_clk;
    ser_clk_div <= pix_clk;
    ser_enable <= enable;
    ser_reset <= reset;

end RTL;

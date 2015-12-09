----------------------------------------------------------------------------
--  cmv_pll.vhd
--	Axiom Alpha CMV PLL
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

library unisim;
use unisim.VCOMPONENTS.ALL;

entity cmv_pll is
    port (
	ref_clk_in : in std_logic;		-- input clock to FPGA
	--
	pll_locked : out std_logic;		-- PLL locked
	--
	lvds_clk : out std_logic;		-- lvds base clock
	cmv_clk : out std_logic;		-- cmv base clock
	spi_clk : out std_logic;		-- spi base clock
	axi_clk : out std_logic;		-- axihp clock
	dly_clk : out std_logic			-- delay ref clock
    );

end entity cmv_pll;


architecture RTL_300MHZ of cmv_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_lvds_clk : std_logic;
    signal pll_cmv_clk : std_logic;
    signal pll_spi_clk : std_logic;
    signal pll_axi_clk : std_logic;
    signal pll_dly_clk : std_logic;

begin
    mmcm_inst : MMCME2_BASE
    generic map (
	BANDWIDTH => "OPTIMIZED",
	CLKIN1_PERIOD => 10.0,
	CLKFBOUT_MULT_F => 12.0,
	CLKOUT0_DIVIDE_F => 4.00,	-- 300MHz CMV LVDS clock
	CLKOUT1_DIVIDE => 1200/300*12,	--  25MHz CMV input [5-30MHz]
	CLKOUT2_DIVIDE => 1200/10,	--  10MHz CMV SPI [0-30MHz]
	CLKOUT3_DIVIDE => 1200/240,	-- 200MHz AXI HP clock
	CLKOUT4_DIVIDE => 1200/200,	-- 200MHz delay ref clock
	--
	CLKOUT0_PHASE => 0.0,
	CLKOUT1_PHASE => 0.0,
	CLKOUT2_PHASE => 0.0,
	CLKOUT3_PHASE => 0.0,
	CLKOUT4_PHASE => 0.0,
	--
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => ref_clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,

	CLKOUT0 => pll_lvds_clk,
	CLKOUT1 => pll_cmv_clk,
	CLKOUT2 => pll_spi_clk,
	CLKOUT3 => pll_axi_clk,
	CLKOUT4 => pll_dly_clk,

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    BUFG_lvds_inst : BUFG
	port map (
	    I => pll_lvds_clk,
	    O => lvds_clk );

    BUFG_cmv_inst : BUFG
	port map (
	    I => pll_cmv_clk,
	    O => cmv_clk );

    BUFG_spi_inst : BUFG
	port map (
	    I => pll_spi_clk,
	    O => spi_clk );

    BUFG_axi_inst : BUFG
	port map (
	    I => pll_axi_clk,
	    O => axi_clk );

    BUFG_dly_inst : BUFG
	port map (
	    I => pll_dly_clk,
	    O => dly_clk );

end RTL_300MHZ;

architecture RTL_288MHZ of cmv_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_lvds_clk : std_logic;
    signal pll_cmv_clk : std_logic;
    signal pll_spi_clk : std_logic;
    signal pll_axi_clk : std_logic;
    signal pll_dly_clk : std_logic;

begin
    mmcm_inst : MMCME2_BASE
    generic map (
	BANDWIDTH => "OPTIMIZED",
	CLKIN1_PERIOD => 10.0,
	CLKFBOUT_MULT_F => 54.0,
	CLKOUT0_DIVIDE_F => 3.75,	-- 288MHz CMV LVDS clock
	CLKOUT1_DIVIDE => 45,		-- 24MHz CMV input [5-30MHz]
	CLKOUT2_DIVIDE => 108,		-- 10.0MHz CMV SPI [0-30MHz]
	CLKOUT3_DIVIDE => 5,		-- 216MHz AXI HP clock
	CLKOUT4_DIVIDE => 5,		-- 216MHz delay ref clock
	--
	CLKOUT0_PHASE => 0.0,
	CLKOUT1_PHASE => 0.0,
	CLKOUT2_PHASE => 0.0,
	CLKOUT3_PHASE => 0.0,
	CLKOUT4_PHASE => 0.0,
	--
	DIVCLK_DIVIDE => 5 )
    port map (
	CLKIN1 => ref_clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,

	CLKOUT0 => pll_lvds_clk,
	CLKOUT1 => pll_cmv_clk,
	CLKOUT2 => pll_spi_clk,
	CLKOUT3 => pll_axi_clk,
	CLKOUT4 => pll_dly_clk,

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    BUFG_lvds_inst : BUFG
	port map (
	    I => pll_lvds_clk,
	    O => lvds_clk );

    BUFG_cmv_inst : BUFG
	port map (
	    I => pll_cmv_clk,
	    O => cmv_clk );

    BUFG_spi_inst : BUFG
	port map (
	    I => pll_spi_clk,
	    O => spi_clk );

    BUFG_axi_inst : BUFG
	port map (
	    I => pll_axi_clk,
	    O => axi_clk );

    BUFG_dly_inst : BUFG
	port map (
	    I => pll_dly_clk,
	    O => dly_clk );

end RTL_288MHZ;

architecture RTL_266MHZ of cmv_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_lvds_clk : std_logic;
    signal pll_cmv_clk : std_logic;
    signal pll_spi_clk : std_logic;
    signal pll_axi_clk : std_logic;
    signal pll_dly_clk : std_logic;

begin
    mmcm_inst : MMCME2_BASE
    generic map (
	BANDWIDTH => "OPTIMIZED",
	CLKIN1_PERIOD => 10.0,
	CLKFBOUT_MULT_F => 10.0,
	CLKOUT0_DIVIDE_F => 3.75,	-- 266MHz CMV LVDS clock
	CLKOUT1_DIVIDE => 45,		-- 22.2MHz CMV input [5-30MHz]
	CLKOUT2_DIVIDE => 100,		-- 10.0MHz CMV SPI [0-30MHz]
	CLKOUT3_DIVIDE => 5,		-- 200MHz AXI HP clock
	CLKOUT4_DIVIDE => 5,		-- 200MHz delay ref clock
	--
	CLKOUT0_PHASE => 0.0,
	CLKOUT1_PHASE => 0.0,
	CLKOUT2_PHASE => 0.0,
	CLKOUT3_PHASE => 0.0,
	CLKOUT4_PHASE => 0.0,
	--
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => ref_clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,

	CLKOUT0 => pll_lvds_clk,
	CLKOUT1 => pll_cmv_clk,
	CLKOUT2 => pll_spi_clk,
	CLKOUT3 => pll_axi_clk,
	CLKOUT4 => pll_dly_clk,

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    BUFG_lvds_inst : BUFG
	port map (
	    I => pll_lvds_clk,
	    O => lvds_clk );

    BUFG_cmv_inst : BUFG
	port map (
	    I => pll_cmv_clk,
	    O => cmv_clk );

    BUFG_spi_inst : BUFG
	port map (
	    I => pll_spi_clk,
	    O => spi_clk );

    BUFG_axi_inst : BUFG
	port map (
	    I => pll_axi_clk,
	    O => axi_clk );

    BUFG_dly_inst : BUFG
	port map (
	    I => pll_dly_clk,
	    O => dly_clk );

end RTL_266MHZ;

architecture RTL_250MHZ of cmv_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_lvds_clk : std_logic;
    signal pll_cmv_clk : std_logic;
    signal pll_spi_clk : std_logic;
    signal pll_axi_clk : std_logic;
    signal pll_dly_clk : std_logic;

begin
    mmcm_inst : MMCME2_BASE
    generic map (
	BANDWIDTH => "OPTIMIZED",
	CLKIN1_PERIOD => 10.0,
	CLKFBOUT_MULT_F => 10.0,
	CLKOUT0_DIVIDE_F => 4.00,	-- 250MHz CMV LVDS clock
	CLKOUT1_DIVIDE => 1000/250*12,	-- 20.8MHz CMV input [5-30MHz]
	CLKOUT2_DIVIDE => 1000/10,	-- 10.0MHz CMV SPI [0-30MHz]
	CLKOUT3_DIVIDE => 1000/200,	-- 200MHz AXI HP clock
	CLKOUT4_DIVIDE => 1000/200,	-- 200MHz delay ref clock
	--
	CLKOUT0_PHASE => 0.0,
	CLKOUT1_PHASE => 0.0,
	CLKOUT2_PHASE => 0.0,
	CLKOUT3_PHASE => 0.0,
	CLKOUT4_PHASE => 0.0,
	--
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => ref_clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,

	CLKOUT0 => pll_lvds_clk,
	CLKOUT1 => pll_cmv_clk,
	CLKOUT2 => pll_spi_clk,
	CLKOUT3 => pll_axi_clk,
	CLKOUT4 => pll_dly_clk,

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    BUFG_lvds_inst : BUFG
	port map (
	    I => pll_lvds_clk,
	    O => lvds_clk );

    BUFG_cmv_inst : BUFG
	port map (
	    I => pll_cmv_clk,
	    O => cmv_clk );

    BUFG_spi_inst : BUFG
	port map (
	    I => pll_spi_clk,
	    O => spi_clk );

    BUFG_axi_inst : BUFG
	port map (
	    I => pll_axi_clk,
	    O => axi_clk );

    BUFG_dly_inst : BUFG
	port map (
	    I => pll_dly_clk,
	    O => dly_clk );

end RTL_250MHZ;

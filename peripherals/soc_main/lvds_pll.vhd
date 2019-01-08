----------------------------------------------------------------------------
--  lvds_pll.vhd
--	AXIOM Alpha LVDS related PLLs
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

entity lvds_pll is
    port (
	ref_clk_in : in std_logic;		-- input clock to FPGA
	--
	pll_locked : out std_logic;		-- PLL locked
	--
	lvds_clk : out std_logic;		-- regenerated clock
	word_clk : out std_logic		-- word clock
    );

end entity lvds_pll;


architecture RTL_300MHZ of lvds_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_lvds_clk : std_logic;
    signal pll_word_clk : std_logic;

begin
    pll_inst : PLLE2_BASE
    generic map (
	CLKIN1_PERIOD => 6.666,
	CLKFBOUT_MULT => 10,
	CLKOUT0_DIVIDE => 1500/300,	-- 300MHz LVDS clock
	CLKOUT1_DIVIDE => 1500/300*6,	--  50MHz WORD clock
	--
	CLKOUT0_PHASE => 0.0,
	CLKOUT1_PHASE => 0.0,
	--
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => ref_clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,
	--
	CLKOUT0 => pll_lvds_clk,
	CLKOUT1 => pll_word_clk,

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    BUFG_lvds_inst : BUFG
	port map (
	    I => pll_lvds_clk,
	    O => lvds_clk );

    BUFG_word_inst : BUFG
	port map (
	    I => pll_word_clk,
	    O => word_clk );

end RTL_300MHZ;

architecture RTL_288MHZ of lvds_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_lvds_clk : std_logic;
    signal pll_word_clk : std_logic;

begin
    pll_inst : PLLE2_BASE
    generic map (
	CLKIN1_PERIOD => 6.944,
	CLKFBOUT_MULT => 10,
	CLKOUT0_DIVIDE => 1440/288,	-- 288MHz LVDS clock
	CLKOUT1_DIVIDE => 1440/288*6,	--  48MHz WORD clock
	--
	CLKOUT0_PHASE => 0.0,
	CLKOUT1_PHASE => 0.0,
	--
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => ref_clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,
	--
	CLKOUT0 => pll_lvds_clk,
	CLKOUT1 => pll_word_clk,

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    BUFG_lvds_inst : BUFG
	port map (
	    I => pll_lvds_clk,
	    O => lvds_clk );

    BUFG_word_inst : BUFG
	port map (
	    I => pll_word_clk,
	    O => word_clk );

end RTL_288MHZ;

architecture RTL_266MHZ of lvds_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_lvds_clk : std_logic;
    signal pll_word_clk : std_logic;

begin
    pll_inst : PLLE2_BASE
    generic map (
	CLKIN1_PERIOD => 7.500,
	CLKFBOUT_MULT => 12,
	CLKOUT0_DIVIDE => 1600/266,	-- 266MHz LVDS clock
	CLKOUT1_DIVIDE => 1600/266*6,	--  44MHz WORD clock
	--
	CLKOUT0_PHASE => 0.0,
	CLKOUT1_PHASE => 0.0,
	--
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => ref_clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,
	--
	CLKOUT0 => pll_lvds_clk,
	CLKOUT1 => pll_word_clk,

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    BUFG_lvds_inst : BUFG
	port map (
	    I => pll_lvds_clk,
	    O => lvds_clk );

    BUFG_word_inst : BUFG
	port map (
	    I => pll_word_clk,
	    O => word_clk );

end RTL_266MHZ;

architecture RTL_250MHZ of lvds_pll is

    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_lvds_clk : std_logic;
    signal pll_word_clk : std_logic;

begin
    pll_inst : PLLE2_BASE
    generic map (
	CLKIN1_PERIOD => 8.0,
	CLKFBOUT_MULT => 12,
	CLKOUT0_DIVIDE => 1500/250,	-- 250MHz LVDS clock
	CLKOUT1_DIVIDE => 1500/250*6,	-- 41.6MHz WORD clock
	--
	CLKOUT0_PHASE => 0.0,
	CLKOUT1_PHASE => 0.0,
	--
	DIVCLK_DIVIDE => 1 )
    port map (
	CLKIN1 => ref_clk_in,
	CLKFBOUT => pll_fbout,
	CLKFBIN => pll_fbin,
	--
	CLKOUT0 => pll_lvds_clk,
	CLKOUT1 => pll_word_clk,

	LOCKED => pll_locked,
	PWRDWN => '0',
	RST => '0' );

    pll_fbin <= pll_fbout;

    BUFG_lvds_inst : BUFG
	port map (
	    I => pll_lvds_clk,
	    O => lvds_clk );

    BUFG_word_inst : BUFG
	port map (
	    I => pll_word_clk,
	    O => word_clk );

end RTL_250MHZ;

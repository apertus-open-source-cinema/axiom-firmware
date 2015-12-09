----------------------------------------------------------------------------
--  hdmi_pll.vhd
--	Axiom Alpha HDMI related PLLs (Reconf)
--	Version 1.1
--
--  Copyright (C) 2013-2014 H.Poetzl
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

package hdmi_pll_pkg is

    type hdmi_config is (
	HDMI_5000KHZ, HDMI_7425KHZ,
	HDMI_120MHZ, HDMI_148MHZ, HDMI_148500KHZ,
	HDMI_148571KHZ, HDMI_160MHZ );

end;


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.hdmi_pll_pkg.ALL;


entity hdmi_pll is
    generic (
	PLL_CONFIG : hdmi_config := HDMI_160MHZ
    );
    port (
	ref_clk_in : in std_logic;		-- input clock to FPGA
	--
	pll_reset : in std_logic;			-- PLL reset
	pll_pwrdwn : in std_logic;		-- PLL power down
	pll_locked : out std_logic;		-- PLL locked
	--
	tmds_clk : out std_logic;		-- TMDS bit clock
	hdmi_clk : out std_logic;		-- HDMI output clock
	data_clk : out std_logic;		-- HDMI data clock
	--
	s_axi_aclk : in std_logic;
	s_axi_areset_n : in std_logic;
	--
	s_axi_ro : out axi3ml_read_in_r;
	s_axi_ri : in axi3ml_read_out_r;
	s_axi_wo : out axi3ml_write_in_r;
	s_axi_wi : in axi3ml_write_out_r
    );

end entity hdmi_pll;


architecture RTL of hdmi_pll is

    type hdmi_config_r is record
	CLKIN1_PERIOD : real;
	CLKFBOUT_MULT_F : real;
	DIVCLK_DIVIDE : natural;
	--
	CLKOUT0_DIVIDE_F : real;
	CLKOUT1_DIVIDE : natural;
	CLKOUT2_DIVIDE : natural;
	--
	CLKOUT0_PHASE : real;
	CLKOUT1_PHASE : real;
	CLKOUT2_PHASE : real;
    end record;

    type hdmi_config_a is array (hdmi_config) of hdmi_config_r;

    constant conf_c : hdmi_config_a := (
	HDMI_5000KHZ => (
	    CLKIN1_PERIOD => 10.000,
	    CLKFBOUT_MULT_F => 62.5,
	    DIVCLK_DIVIDE => 10,
	    --
	    CLKOUT0_DIVIDE_F => 25.0,
	    CLKOUT1_DIVIDE => 125,
	    CLKOUT2_DIVIDE => 125,
	    --
	    CLKOUT0_PHASE => 0.0,
	    CLKOUT1_PHASE => 0.0,
	    CLKOUT2_PHASE => 0.0 ),

	HDMI_7425KHZ => (
	    CLKIN1_PERIOD => 10.000,
	    CLKFBOUT_MULT_F => 37.125,
	    DIVCLK_DIVIDE => 5,
	    --
	    CLKOUT0_DIVIDE_F => 20.0,
	    CLKOUT1_DIVIDE => 100,
	    CLKOUT2_DIVIDE => 100,
	    --
	    CLKOUT0_PHASE => 0.0,
	    CLKOUT1_PHASE => 0.0,
	    CLKOUT2_PHASE => 0.0 ),

	HDMI_120MHZ => (
	    CLKIN1_PERIOD => 10.000,
	    CLKFBOUT_MULT_F => 24.000,
	    DIVCLK_DIVIDE => 2,
	    --
	    CLKOUT0_DIVIDE_F => 2.0,
	    CLKOUT1_DIVIDE => 10,
	    CLKOUT2_DIVIDE => 10,
	    --
	    CLKOUT0_PHASE => 0.0,
	    CLKOUT1_PHASE => 0.0,
	    CLKOUT2_PHASE => 0.0 ),

	HDMI_148MHZ => (
	    CLKIN1_PERIOD => 10.000,
	    CLKFBOUT_MULT_F => 37.000,
	    DIVCLK_DIVIDE => 5,
	    --
	    CLKOUT0_DIVIDE_F => 1.0,
	    CLKOUT1_DIVIDE => 5,
	    CLKOUT2_DIVIDE => 5,
	    --
	    CLKOUT0_PHASE => 0.0,
	    CLKOUT1_PHASE => 0.0,
	    CLKOUT2_PHASE => 0.0 ),

	HDMI_148500KHZ => (
	    CLKIN1_PERIOD => 10.000,
	    CLKFBOUT_MULT_F => 37.125,
	    DIVCLK_DIVIDE => 5,
	    --
	    CLKOUT0_DIVIDE_F => 1.0,
	    CLKOUT1_DIVIDE => 5,
	    CLKOUT2_DIVIDE => 5,
	    --
	    CLKOUT0_PHASE => 0.0,
	    CLKOUT1_PHASE => 0.0,
	    CLKOUT2_PHASE => 0.0 ),

	HDMI_148571KHZ => (
	    CLKIN1_PERIOD => 10.000,
	    CLKFBOUT_MULT_F => 52.0,
	    DIVCLK_DIVIDE => 5,
	    --
	    CLKOUT0_DIVIDE_F => 1.4,
	    CLKOUT1_DIVIDE => 7,
	    CLKOUT2_DIVIDE => 7,
	    --
	    CLKOUT0_PHASE => 0.0,
	    CLKOUT1_PHASE => 0.0,
	    CLKOUT2_PHASE => 0.0 ),

	HDMI_160MHZ => (
	    CLKIN1_PERIOD => 10.000,
	    CLKFBOUT_MULT_F => 8.0,
	    DIVCLK_DIVIDE => 1,
	    --
	    CLKOUT0_DIVIDE_F => 1.0,
	    CLKOUT1_DIVIDE => 5,
	    CLKOUT2_DIVIDE => 5,
	    --
	    CLKOUT0_PHASE => 0.0,
	    CLKOUT1_PHASE => 0.0,
	    CLKOUT2_PHASE => 0.0 ));


    signal pll_fbout : std_logic;
    signal pll_fbin : std_logic;

    signal pll_tmds_clk : std_logic;
    signal pll_hdmi_clk : std_logic;
    signal pll_data_clk : std_logic;

    signal pll_dclk : std_logic;
    signal pll_den : std_logic;
    signal pll_dwe : std_logic;
    signal pll_drdy : std_logic;

    signal pll_daddr : std_logic_vector(6 downto 0);
    signal pll_do : std_logic_vector(15 downto 0);
    signal pll_di : std_logic_vector(15 downto 0);

    signal pll_psclk : std_logic := '0';
    signal pll_psen : std_logic := '0';
    signal pll_psincdec : std_logic := '0';

begin
    mmcm_inst : MMCME2_ADV
	generic map (
	    BANDWIDTH => "LOW",
	    CLKIN1_PERIOD => conf_c(PLL_CONFIG).CLKIN1_PERIOD,
	    CLKFBOUT_MULT_F => conf_c(PLL_CONFIG).CLKFBOUT_MULT_F,
	    CLKOUT0_DIVIDE_F => conf_c(PLL_CONFIG).CLKOUT0_DIVIDE_F,
	    CLKOUT1_DIVIDE => conf_c(PLL_CONFIG).CLKOUT1_DIVIDE,
	    CLKOUT2_DIVIDE => conf_c(PLL_CONFIG).CLKOUT2_DIVIDE,
	    --
	    CLKOUT0_PHASE => conf_c(PLL_CONFIG).CLKOUT0_PHASE,
	    CLKOUT1_PHASE => conf_c(PLL_CONFIG).CLKOUT1_PHASE,
	    CLKOUT2_PHASE => conf_c(PLL_CONFIG).CLKOUT2_PHASE,
	    --
	    DIVCLK_DIVIDE => conf_c(PLL_CONFIG).DIVCLK_DIVIDE )
	port map (
	    CLKIN1 => ref_clk_in,
	    CLKIN2 => ref_clk_in,
	    CLKINSEL => '1',
	    CLKFBOUT => pll_fbout,
	    CLKFBIN => pll_fbin,

	    CLKOUT0 => pll_tmds_clk,
	    CLKOUT1 => pll_hdmi_clk,
	    CLKOUT2 => pll_data_clk,

	    LOCKED => pll_locked,
	    PWRDWN => pll_pwrdwn,
	    RST => pll_reset,
	    --
	    DCLK => pll_dclk,
	    DEN => pll_den,
	    DWE => pll_dwe,
	    DRDY => pll_drdy,
	    --
	    DADDR => pll_daddr,
	    DO => pll_do,
	    DI => pll_di,
	    --
	    PSCLK => pll_psclk,
	    PSEN => pll_psen,
	    PSINCDEC => pll_psincdec );

    pll_fbin <= pll_fbout;

    reg_pll_inst : entity work.reg_pll
	port map (
	    s_axi_aclk => s_axi_aclk,
	    s_axi_areset_n => s_axi_areset_n,
	    --
	    s_axi_ro => s_axi_ro,
	    s_axi_ri => s_axi_ri,
	    s_axi_wo => s_axi_wo,
	    s_axi_wi => s_axi_wi,
	    --
	    pll_dclk => pll_dclk,
	    pll_den => pll_den,
	    pll_dwe => pll_dwe,
	    pll_drdy => pll_drdy,
	    --
	    pll_daddr => pll_daddr,
	    pll_dout => pll_do,
	    pll_din => pll_di );

    BUFG_tmds_inst : BUFG
	port map (
	    I => pll_tmds_clk,
	    O => tmds_clk );

    BUFG_hdmi_inst : BUFG
	port map (
	    I => pll_hdmi_clk,
	    O => hdmi_clk );

    BUFG_data_inst : BUFG
	port map (
	    I => pll_data_clk,
	    O => data_clk );

end RTL;



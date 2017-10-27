----------------------------------------------------------------------------
--  top.vhd (for cmv_hdmi)
--	Axiom Beta CMV HDMI Test
--	Version 1.3
--
--  Copyright (C) 2013-2015 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--
--  Vivado 2014.2:
--    mkdir -p build.vivado
--    (cd build.vivado && vivado -mode tcl -source ../vivado.tcl)
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

library unimacro;
use unimacro.VCOMPONENTS.ALL;

use work.axi3m_pkg.ALL;		-- AXI3 Master
use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.axi3s_pkg.ALL;		-- AXI3 Slave

use work.reduce_pkg.ALL;	-- Logic Reduction
use work.vivado_pkg.ALL;	-- Vivado Attributes

use work.fifo_pkg.ALL;		-- FIFO Functions
use work.reg_array_pkg.ALL;	-- Register Arrays
use work.par_array_pkg.ALL;	-- Parallel Data
use work.lut_array_pkg.ALL;	-- Block RAM Arrays
use work.hdmi_pll_pkg.ALL;	-- HDMI PLL Configs
use work.vec_mat_pkg.ALL;	-- Vector/Matrix
use work.helper_pkg.ALL;	-- Vivado Attributes
use work.vec_mat_pkg.ALL;	-- Vector Types


entity top is
    port (
	i2c_scl : inout std_ulogic;
	i2c_sda : inout std_ulogic;
	--
	spi_en : out std_ulogic;
	spi_clk : out std_ulogic;
	spi_in : out std_ulogic;
	spi_out : in std_ulogic;
	--
	cmv_clk : out std_ulogic;
	cmv_sys_res_n : out std_ulogic;
	cmv_frame_req : out std_ulogic;
	cmv_t_exp1 : out std_ulogic;
	cmv_t_exp2 : out std_ulogic;
	--
	cmv_lvds_clk_p : out std_logic;
	cmv_lvds_clk_n : out std_logic;
	--
	cmv_lvds_outclk_p : in std_logic;
	cmv_lvds_outclk_n : in std_logic;
	--
	cmv_lvds_data_p : in unsigned(31 downto 0);
	cmv_lvds_data_n : in unsigned(31 downto 0);
	--
	cmv_lvds_ctrl_p : in std_logic;
	cmv_lvds_ctrl_n : in std_logic;
	--
	hdmi_south_clk_p : out std_logic;
	hdmi_south_clk_n : out std_logic;
	--
	hdmi_south_d_p : out std_logic_vector (2 downto 0);
	hdmi_south_d_n : out std_logic_vector (2 downto 0);
	--
    /*	hdmi_north_clk_p : out std_logic;
	hdmi_north_clk_n : out std_logic;
	--
	hdmi_north_d_p : out std_logic_vector (2 downto 0);
	hdmi_north_d_n : out std_logic_vector (2 downto 0);	*/
	--
	debug_tmds: out std_logic_vector (3 downto 0);
	debug : out std_logic_vector (3 downto 0)
    );

end entity top;


architecture RTL of top is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal clk_100 : std_logic;

    signal debug_data : std_logic_vector (3 downto 0);
    signal debug_data_d : std_logic_vector (3 downto 0);

    signal hd_de : std_logic;
    signal hd_terc : std_logic;

    signal hd_hsync : std_logic;
    signal hd_vsync : std_logic;
    signal hd_pream : std_logic_vector (1 downto 0);
    signal hd_guard : std_logic_vector (2 downto 0);

    --------------------------------------------------------------------
    -- TMDS Signals
    --------------------------------------------------------------------

    signal tmds_south_io : std_logic_vector (3 downto 0);
    signal tmds_north_io : std_logic_vector (3 downto 0);

    signal tmds_enable : std_logic := '1';
    signal tmds_reset : std_logic := '0';

    signal rgb_data : vec8_a (2 downto 0) :=
	(others => (others => '0'));

    signal dil_data : std_logic_vector (8 downto 0);
    signal dil_de : std_logic;

    signal rgb_de : std_logic;
    signal rgb_blank : std_logic;

    signal rgb_hsync : std_logic;
    signal rgb_vsync : std_logic;
    signal rgb_pream : std_logic_vector (1 downto 0);
    signal rgb_guard : std_logic_vector (2 downto 0);

    signal btn : std_logic_vector (4 downto 0) := (others => '0');
    signal swi : std_logic_vector (7 downto 0) := (others => '0');
    signal led : std_logic_vector (7 downto 0);

    --------------------------------------------------------------------
    -- PS7 Signals
    --------------------------------------------------------------------

    signal ps_fclk : std_logic_vector (3 downto 0);
    signal ps_reset_n : std_logic_vector (3 downto 0);

    --------------------------------------------------------------------
    -- PS7 AXI CMV Master Signals
    --------------------------------------------------------------------

    signal m_axi0_aclk : std_logic;
    signal m_axi0_areset_n : std_logic;

    signal m_axi0_ri : axi3m_read_in_r;
    signal m_axi0_ro : axi3m_read_out_r;
    signal m_axi0_wi : axi3m_write_in_r;
    signal m_axi0_wo : axi3m_write_out_r;

    signal m_axi0l_ri : axi3ml_read_in_r;
    signal m_axi0l_ro : axi3ml_read_out_r;
    signal m_axi0l_wi : axi3ml_write_in_r;
    signal m_axi0l_wo : axi3ml_write_out_r;

    signal m_axi0a_aclk : std_logic_vector (7 downto 0);
    signal m_axi0a_areset_n : std_logic_vector (7 downto 0);

    signal m_axi0a_ri : axi3ml_read_in_a(7 downto 0);
    signal m_axi0a_ro : axi3ml_read_out_a(7 downto 0);
    signal m_axi0a_wi : axi3ml_write_in_a(7 downto 0);
    signal m_axi0a_wo : axi3ml_write_out_a(7 downto 0);

    --------------------------------------------------------------------
    -- PS7 AXI HDMI Master Signals
    --------------------------------------------------------------------

    signal m_axi1_aclk : std_logic;
    signal m_axi1_areset_n : std_logic;

    signal m_axi1_ri : axi3m_read_in_r;
    signal m_axi1_ro : axi3m_read_out_r;
    signal m_axi1_wi : axi3m_write_in_r;
    signal m_axi1_wo : axi3m_write_out_r;

    signal m_axi1l_ri : axi3ml_read_in_r;
    signal m_axi1l_ro : axi3ml_read_out_r;
    signal m_axi1l_wi : axi3ml_write_in_r;
    signal m_axi1l_wo : axi3ml_write_out_r;

    signal m_axi1a_aclk : std_logic_vector (7 downto 0);
    signal m_axi1a_areset_n : std_logic_vector (7 downto 0);

    signal m_axi1a_ri : axi3ml_read_in_a(7 downto 0);
    signal m_axi1a_ro : axi3ml_read_out_a(7 downto 0);
    signal m_axi1a_wi : axi3ml_write_in_a(7 downto 0);
    signal m_axi1a_wo : axi3ml_write_out_a(7 downto 0);

    --------------------------------------------------------------------
    -- PS7 AXI Slave Signals
    --------------------------------------------------------------------

    signal s_axi_aclk : std_logic_vector (3 downto 0);
    signal s_axi_areset_n : std_logic_vector (3 downto 0);

    signal s_axi_ri : axi3s_read_in_a(3 downto 0);
    signal s_axi_ro : axi3s_read_out_a(3 downto 0);
    signal s_axi_wi : axi3s_write_in_a(3 downto 0);
    signal s_axi_wo : axi3s_write_out_a(3 downto 0);

    --------------------------------------------------------------------
    -- PS7 EMIO GPIO Signals
    --------------------------------------------------------------------

    signal emio_gpio_i : std_logic_vector(63 downto 0);
    signal emio_gpio_o : std_logic_vector(63 downto 0);
    signal emio_gpio_t_n : std_logic_vector(63 downto 0);

    --------------------------------------------------------------------
    -- I2C0 Signals
    --------------------------------------------------------------------

    signal i2c0_sda_i : std_ulogic;
    signal i2c0_sda_o : std_ulogic;
    signal i2c0_sda_t : std_ulogic;
    signal i2c0_sda_t_n : std_ulogic;

    signal i2c0_scl_i : std_ulogic;
    signal i2c0_scl_o : std_ulogic;
    signal i2c0_scl_t : std_ulogic;
    signal i2c0_scl_t_n : std_ulogic;

    --------------------------------------------------------------------
    -- I2C1 Signals
    --------------------------------------------------------------------

    signal i2c1_sda_i : std_ulogic;
    signal i2c1_sda_o : std_ulogic;
    signal i2c1_sda_t : std_ulogic;
    signal i2c1_sda_t_n : std_ulogic;

    signal i2c1_scl_i : std_ulogic;
    signal i2c1_scl_o : std_ulogic;
    signal i2c1_scl_t : std_ulogic;
    signal i2c1_scl_t_n : std_ulogic;

    --------------------------------------------------------------------
    -- CMV MMCM Signals
    --------------------------------------------------------------------

    signal cmv_pll_locked : std_ulogic;

    signal cmv_lvds_clk : std_ulogic;
    signal cmv_cmd_clk : std_ulogic;
    signal cmv_spi_clk : std_ulogic;
    signal cmv_axi_clk : std_ulogic;
    signal cmv_dly_clk : std_ulogic;

    --------------------------------------------------------------------
    -- LVDS PLL Signals
    --------------------------------------------------------------------

    signal lvds_pll_locked : std_ulogic;

    signal lvds_clk : std_ulogic;
    signal word_clk : std_ulogic;

    signal cmv_outclk : std_ulogic;

    --------------------------------------------------------------------
    -- HDMI MMCM Signals
    --------------------------------------------------------------------

    signal hdmi_pll_locked : std_ulogic;

    signal tmds_clk : std_ulogic;
    signal hdmi_clk : std_ulogic;
    signal data_clk : std_ulogic;

    --------------------------------------------------------------------
    -- LVDS IDELAY Signals
    --------------------------------------------------------------------

    constant CHANNELS : natural := 32;

    signal idelay_valid : std_logic;

    signal idelay_in_p : std_logic_vector (CHANNELS + 1 downto 0);
    signal idelay_in_n : std_logic_vector (CHANNELS + 1 downto 0);
    signal idelay_in : std_logic_vector (CHANNELS + 1 downto 0);
    signal idelay_out : std_logic_vector (CHANNELS + 1 downto 0);
    signal ser_out : std_logic_vector (CHANNELS + 1 downto 0)
	:= (others => '0');

    --------------------------------------------------------------------
    -- CMV Serdes Signals
    --------------------------------------------------------------------

    alias serdes_clk : std_logic is lvds_clk;
    alias serdes_clkdiv : std_logic is word_clk;

    signal serdes_phase : std_logic;

    signal serdes_bitslip : std_logic_vector (CHANNELS + 1 downto 0);

    --------------------------------------------------------------------
    -- CMV Parallel Data Signals
    --------------------------------------------------------------------

    signal par_data : par12_a (CHANNELS downto 0);
    signal par_data_e : par12_a (CHANNELS downto 0);
    signal par_data_o : par12_a (CHANNELS downto 0);

    alias par_ctrl : std_logic_vector (11 downto 0)
	is par_data(CHANNELS);
    signal par_ctrl_d : std_logic_vector (11 downto 0);

    signal par_valid : std_logic;
    signal par_valid_d : std_logic;
    signal par_enable : std_logic;

    signal par_pattern : par12_a (CHANNELS downto 0);
    signal par_match : std_logic_vector (CHANNELS + 1 downto 0);
    signal par_mismatch : std_logic_vector (CHANNELS + 1 downto 0);

    --------------------------------------------------------------------
    -- Remapper Signals
    --------------------------------------------------------------------

    signal map_ctrl : std_logic_vector (11 downto 0);
    signal map_data : par12_a (CHANNELS - 1 downto 0);

    signal remap_ctrl : std_logic_vector (11 downto 0);
    signal remap_data : par12_a (CHANNELS - 1 downto 0);

    signal chop_enable : std_logic;

    --------------------------------------------------------------------
    -- CMV Register File Signals
    --------------------------------------------------------------------

    constant REG_SPLIT : natural := 8;
    constant OREG_SIZE : natural := 16;

    signal reg_oreg : reg32_a(0 to OREG_SIZE - 1);

    alias waddr_buf0 : std_logic_vector (31 downto 0)
	is reg_oreg(0)(31 downto 0);

    alias waddr_pat0 : std_logic_vector (31 downto 0)
	is reg_oreg(1)(31 downto 0);

    alias waddr_buf1 : std_logic_vector (31 downto 0)
	is reg_oreg(2)(31 downto 0);

    alias waddr_pat1 : std_logic_vector (31 downto 0)
	is reg_oreg(3)(31 downto 0);

    alias waddr_buf2 : std_logic_vector (31 downto 0)
	is reg_oreg(4)(31 downto 0);

    alias waddr_pat2 : std_logic_vector (31 downto 0)
	is reg_oreg(5)(31 downto 0);

    alias waddr_buf3 : std_logic_vector (31 downto 0)
	is reg_oreg(6)(31 downto 0);

    alias waddr_pat3 : std_logic_vector (31 downto 0)
	is reg_oreg(7)(31 downto 0);

    alias waddr_cinc : std_logic_vector (31 downto 0)
	is reg_oreg(8)(31 downto 0);

    alias waddr_rinc : std_logic_vector (31 downto 0)
	is reg_oreg(9)(31 downto 0);

    alias waddr_ccnt : std_logic_vector (11 downto 0)
	is reg_oreg(10)(11 downto 0);

    alias fifo_data_reset : std_logic is reg_oreg(11)(0);

    alias oreg_wblock : std_logic is reg_oreg(11)(4);
    alias oreg_wreset : std_logic is reg_oreg(11)(5);
    alias oreg_wload : std_logic is reg_oreg(11)(6);
    alias oreg_wswitch : std_logic is reg_oreg(11)(7);

    alias serdes_reset : std_logic is reg_oreg(11)(8);

    alias wbuf_enable : std_logic_vector (3 downto 0)
	is reg_oreg(11)(15 downto 12);

    alias writer_enable : std_logic_vector (3 downto 0)
	is reg_oreg(11)(19 downto 16);

    alias rcn_clip : std_logic_vector (1 downto 0)
	is reg_oreg(11)(21 downto 20);

    alias write_strobe : std_logic_vector (7 downto 0)
	is reg_oreg(11)(31 downto 24);

    alias reg_pattern : std_logic_vector (11 downto 0)
	is reg_oreg(12)(11 downto 0);

    alias reg_mval : std_logic_vector (2 downto 0)
	is reg_oreg(13)(0 + 2 downto 0);

    alias reg_mask : std_logic_vector (2 downto 0)
	is reg_oreg(13)(8 + 2 downto 8);

    alias reg_amsk : std_logic_vector (2 downto 0)
	is reg_oreg(13)(16 + 2 downto 16);

    alias led_val : std_logic_vector (7 downto 0)
	is reg_oreg(14)(7 downto 0);

    alias i2c1_sel : std_logic_vector (1 downto 0)
	is reg_oreg(14)(13 downto 12);

    alias led_mask : std_logic_vector (7 downto 0)
	is reg_oreg(14)(23 downto 16);

    alias swi_val : std_logic_vector (7 downto 0)
	is reg_oreg(15)(7 downto 0);

    alias btn_val : std_logic_vector (4 downto 0)
	is reg_oreg(15)(8 + 4 downto 8);

    alias swi_mask : std_logic_vector (7 downto 0)
	is reg_oreg(15)(23 downto 16);

    alias btn_mask : std_logic_vector (4 downto 0)
	is reg_oreg(15)(24 + 4 downto 24);


    constant IREG_SIZE : natural := 8;

    signal led_done : std_logic;

    signal reg_ireg : reg32_a(0 to IREG_SIZE - 1);

    signal usr_access : std_logic_vector (31 downto 0);

    --------------------------------------------------------------------
    -- AddrGen Register File Signals
    --------------------------------------------------------------------

    constant GEN_SPLIT : natural := 8;
    constant OGEN_SIZE : natural := 16;

    signal reg_ogen : reg32_a(0 to OGEN_SIZE - 1);

    alias raddr_buf0 : std_logic_vector (31 downto 0)
	is reg_ogen(0)(31 downto 0);

    alias raddr_pat0 : std_logic_vector (31 downto 0)
	is reg_ogen(1)(31 downto 0);

    alias raddr_buf1 : std_logic_vector (31 downto 0)
	is reg_ogen(2)(31 downto 0);

    alias raddr_pat1 : std_logic_vector (31 downto 0)
	is reg_ogen(3)(31 downto 0);

    alias raddr_buf2 : std_logic_vector (31 downto 0)
	is reg_ogen(4)(31 downto 0);

    alias raddr_pat2 : std_logic_vector (31 downto 0)
	is reg_ogen(5)(31 downto 0);

    alias raddr_buf3 : std_logic_vector (31 downto 0)
	is reg_ogen(6)(31 downto 0);

    alias raddr_pat3 : std_logic_vector (31 downto 0)
	is reg_ogen(7)(31 downto 0);

    alias raddr_cinc : std_logic_vector (31 downto 0)
	is reg_ogen(8)(31 downto 0);

    alias raddr_rinc : std_logic_vector (31 downto 0)
	is reg_ogen(9)(31 downto 0);

    alias raddr_ccnt : std_logic_vector (11 downto 0)
	is reg_ogen(10)(11 downto 0);

    alias fifo_hdmi_reset : std_logic is reg_ogen(11)(0);

    alias ogen_rblock : std_logic is reg_ogen(11)(4);
    alias ogen_rreset : std_logic is reg_ogen(11)(5);
    alias ogen_rload : std_logic is reg_ogen(11)(6);
    alias ogen_rswitch : std_logic is reg_ogen(11)(7);

    alias hdmi_pll_reset : std_logic is reg_ogen(11)(8);
    alias hdmi_pll_pwrdwn : std_logic is reg_ogen(11)(9);

    alias rbuf_enable : std_logic_vector (3 downto 0)
	is reg_ogen(11)(15 downto 12);

    alias reader_enable : std_logic_vector (3 downto 0)
	is reg_ogen(11)(19 downto 16);

    alias overlay_enable : std_logic is reg_ogen(11)(24);

    alias ogen_code0 : std_logic_vector (31 downto 0)
	is reg_ogen(12)(31 downto 0);

    alias ogen_code1 : std_logic_vector (31 downto 0)
	is reg_ogen(13)(31 downto 0);

    alias ogen_code2 : std_logic_vector (31 downto 0)
	is reg_ogen(14)(31 downto 0);

    alias ogen_code3 : std_logic_vector (31 downto 0)
	is reg_ogen(15)(31 downto 0);


    constant IGEN_SIZE : natural := 3;

    signal reg_igen : reg32_a(0 to IGEN_SIZE - 1);

    --------------------------------------------------------------------
    -- Scan Register File Signals
    --------------------------------------------------------------------

    constant SCN_SPLIT : natural := 8;
    constant OSCN_SIZE : natural := 18;

    signal reg_oscn : reg32_a(0 to OSCN_SIZE - 1);

    constant ISCN_SIZE : natural := 2;

    signal reg_iscn : reg32_a(0 to ISCN_SIZE - 1);

    --------------------------------------------------------------------
    -- Matrix Register File Signals
    --------------------------------------------------------------------

    constant MAT_SPLIT : natural := 8;
    constant OMAT_SIZE : natural := 36;

    signal reg_omat : reg32_a(0 to OMAT_SIZE - 1);

    constant IMAT_SIZE : natural := 1;

    signal reg_imat : reg32_a(0 to IMAT_SIZE - 1);

    --------------------------------------------------------------------
    -- Color Matrix Signals
    --------------------------------------------------------------------

    signal mat_values : mat16_4x4;
    signal mat_adjust : mat16_4x4;
    signal mat_offset : vec16_4;

    signal mat_v_in   : vec12_4;
    signal mat_v_out  : vec12_4;

    --------------------------------------------------------------------
    -- Override Signals
    --------------------------------------------------------------------

    signal led_out : std_logic_vector (7 downto 0);
    signal swi_ovr : std_logic_vector (7 downto 0);
    signal btn_ovr : std_logic_vector (4 downto 0);

    --------------------------------------------------------------------
    -- Reader and Writer Constants and Signals
    --------------------------------------------------------------------

    constant DATA_WIDTH : natural := 64;

    constant ADDR_WIDTH : natural := 32;

    type addr_a is array (natural range <>) of
	std_logic_vector (ADDR_WIDTH - 1 downto 0);

    constant RADDR_MASK : addr_a(0 to 3) := 
	( x"07FFFFFF", x"07FFFFFF", x"07FFFFFF", x"07FFFFFF" );
    constant RADDR_BASE : addr_a(0 to 3) := 
	( x"18000000", x"20000000", x"18000000", x"20000000" );

    constant WADDR_MASK : addr_a(0 to 3) := 
	( x"07FFFFFF", x"07FFFFFF", x"07FFFFFF", x"07FFFFFF" );
    constant WADDR_BASE : addr_a(0 to 3) := 
	( x"18000000", x"20000000", x"18000000", x"20000000" );

    --------------------------------------------------------------------
    -- Reader Constants and Signals
    --------------------------------------------------------------------

    signal rdata_clk : std_logic;
    signal rdata_enable : std_logic;
    signal rdata_out : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal rdata_full : std_logic;

    signal rdata_empty : std_logic;

    signal raddr_clk : std_logic;
    signal raddr_enable : std_logic;
    signal raddr_in : std_logic_vector (ADDR_WIDTH - 1 downto 0);
    signal raddr_empty : std_logic;

    signal raddr_match : std_logic;
    signal raddr_sel : std_logic_vector (1 downto 0);
    signal raddr_sel_in : std_logic_vector (1 downto 0);

    signal rbuf_sel : std_logic_vector (1 downto 0);

    alias reader_clk : std_logic is cmv_axi_clk;

    signal reader_inactive : std_logic_vector (3 downto 0);
    signal reader_error : std_logic_vector (3 downto 0);

    signal reader_active : std_logic_vector (3 downto 0);

    signal raddr_reset : std_logic;
    signal raddr_load : std_logic;
    signal raddr_switch : std_logic;
    signal raddr_block : std_logic;

    --------------------------------------------------------------------
    -- Writer Constants and Signals
    --------------------------------------------------------------------

    signal wdata_clk : std_logic;
    signal wdata_enable : std_logic;
    signal wdata_in : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal wdata_empty : std_logic;

    signal wdata_full : std_logic;

    signal waddr_clk : std_logic;
    signal waddr_enable : std_logic;
    signal waddr_in : std_logic_vector (ADDR_WIDTH - 1 downto 0);
    signal waddr_empty : std_logic;

    signal waddr_match : std_logic;
    signal waddr_sel : std_logic_vector (1 downto 0);
    signal waddr_sel_in : std_logic_vector (1 downto 0);

    signal wbuf_sel : std_logic_vector (1 downto 0);

    alias writer_clk : std_logic is cmv_axi_clk;

    signal writer_inactive : std_logic_vector (3 downto 0);
    signal writer_error : std_logic_vector (3 downto 0);

    signal writer_active : std_logic_vector (3 downto 0);
    signal writer_unconf : std_logic_vector (3 downto 0);

    signal waddr_reset : std_logic;
    signal waddr_load : std_logic;
    signal waddr_switch : std_logic;
    signal waddr_block : std_logic;

    --------------------------------------------------------------------
    -- Data FIFO Signals
    --------------------------------------------------------------------

    signal fifo_data_in : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal fifo_data_out : std_logic_vector (DATA_WIDTH - 1 downto 0);

    constant DATA_CWIDTH : natural := cwidth_f(DATA_WIDTH, "36Kb");

    signal fifo_data_rdcount : std_logic_vector (DATA_CWIDTH - 1 downto 0);
    signal fifo_data_wrcount : std_logic_vector (DATA_CWIDTH - 1 downto 0);

    signal fifo_data_wclk : std_logic;
    signal fifo_data_wen : std_logic;
    signal fifo_data_high : std_logic;
    signal fifo_data_full : std_logic;
    signal fifo_data_wrerr : std_logic;

    signal fifo_data_rclk : std_logic;
    signal fifo_data_ren : std_logic;
    signal fifo_data_low : std_logic;
    signal fifo_data_empty : std_logic;
    signal fifo_data_rderr : std_logic;

    signal fifo_data_rst : std_logic;
    signal fifo_data_rrdy : std_logic;
    signal fifo_data_wrdy : std_logic;

    signal data_ctrl : std_logic_vector (11 downto 0);
    signal data_ctrl_d : std_logic_vector (11 downto 0);
    signal data_ctrl_dd : std_logic_vector (11 downto 0);
    signal data_ctrl_ddd : std_logic_vector (11 downto 0);

    alias data_dval : std_logic is data_ctrl(0);
    alias data_lval : std_logic is data_ctrl(1);
    alias data_fval : std_logic is data_ctrl(2);

    alias data_dval_d : std_logic is data_ctrl_d(0);
    alias data_lval_d : std_logic is data_ctrl_d(1);
    alias data_fval_d : std_logic is data_ctrl_d(2);

    alias data_dval_dd : std_logic is data_ctrl_dd(0);
    alias data_lval_dd : std_logic is data_ctrl_dd(1);
    alias data_fval_dd : std_logic is data_ctrl_dd(2);

    alias data_fot : std_logic is data_ctrl(3);
    alias data_inte1 : std_logic is data_ctrl(4);
    alias data_inte2 : std_logic is data_ctrl(5);

    signal match_en : std_logic;
    signal match_en_d : std_logic;

    signal data_wen : std_logic_vector (0 downto 0);
    signal data_wen_d : std_logic_vector (0 downto 0);
    signal data_wen_dd : std_logic_vector (0 downto 0);

    signal data_rcn_wen : std_logic;

    signal data_in : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal data_in_d : std_logic_vector (DATA_WIDTH - 1 downto 0);
    -- signal data_in_dd : std_logic_vector (DATA_WIDTH - 1 downto 0);

    signal data_rcn : std_logic_vector (DATA_WIDTH - 1 downto 0);

    signal llut_dout_ch0 : std_logic_vector (17 downto 0);
    signal llut_dout_ch1 : std_logic_vector (17 downto 0);
    signal llut_dout_ch2 : std_logic_vector (17 downto 0);
    signal llut_dout_ch3 : std_logic_vector (17 downto 0);

    signal llut_dout_ch0_d : std_logic_vector (17 downto 0);
    signal llut_dout_ch1_d : std_logic_vector (17 downto 0);
    signal llut_dout_ch2_d : std_logic_vector (17 downto 0);
    signal llut_dout_ch3_d : std_logic_vector (17 downto 0);

    signal llut_dout_ch0_dd : std_logic_vector (17 downto 0);
    signal llut_dout_ch1_dd : std_logic_vector (17 downto 0);
    signal llut_dout_ch2_dd : std_logic_vector (17 downto 0);
    signal llut_dout_ch3_dd : std_logic_vector (17 downto 0);

    signal data_rcn_ch0 : std_logic_vector (15 downto 0);
    signal data_rcn_ch1 : std_logic_vector (15 downto 0);
    signal data_rcn_ch2 : std_logic_vector (15 downto 0);
    signal data_rcn_ch3 : std_logic_vector (15 downto 0);

    --------------------------------------------------------------------
    -- HDMI FIFO Signals
    --------------------------------------------------------------------

    signal fifo_hdmi_in : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal fifo_hdmi_out : std_logic_vector (DATA_WIDTH - 1 downto 0);

    constant HDMI_CWIDTH : natural := cwidth_f(DATA_WIDTH, "36Kb");

    signal fifo_hdmi_rdcount : std_logic_vector (HDMI_CWIDTH - 1 downto 0);
    signal fifo_hdmi_wrcount : std_logic_vector (HDMI_CWIDTH - 1 downto 0);

    signal fifo_hdmi_wclk : std_logic;
    signal fifo_hdmi_wen : std_logic;
    signal fifo_hdmi_high : std_logic;
    signal fifo_hdmi_full : std_logic;
    signal fifo_hdmi_wrerr : std_logic;

    signal fifo_hdmi_rclk : std_logic;
    signal fifo_hdmi_ren : std_logic;
    signal fifo_hdmi_low : std_logic;
    signal fifo_hdmi_empty : std_logic;
    signal fifo_hdmi_rderr : std_logic;

    signal fifo_hdmi_rst : std_logic;
    signal fifo_hdmi_rrdy : std_logic;
    signal fifo_hdmi_wrdy : std_logic;

    signal hdmi_enable : std_logic;

    signal hdmi_in : std_logic_vector (DATA_WIDTH - 1 downto 0);

    alias hdmi_ch0 : std_logic_vector (11 downto 0)
	is hdmi_in (63 downto 52);
    alias hdmi_ch1 : std_logic_vector (11 downto 0)
	is hdmi_in (51 downto 40);
    alias hdmi_ch2 : std_logic_vector (11 downto 0)
	is hdmi_in (39 downto 28);
    alias hdmi_ch3 : std_logic_vector (11 downto 0)
	is hdmi_in (27 downto 16);
    alias hdmi_ch4 : std_logic_vector (15 downto 0)
	is hdmi_in (15 downto 0);

    signal hdmi_ch4_d : std_logic_vector (15 downto 0);

    signal conv_out : std_logic_vector (63 downto 0);
    signal hdmi_out : std_logic_vector (63 downto 0);

    signal hd_edata : std_logic_vector(31 downto 0);
    signal hd_odata : std_logic_vector(31 downto 0);
    signal hd_sdata : std_logic_vector(31 downto 0);

    signal hd_code : std_logic_vector(63 downto 0);

    alias hd_r : std_logic_vector (11 downto 0)
	is hd_code (63 downto 52);
    alias hd_g1 : std_logic_vector (11 downto 0)
	is hd_code (47 downto 36);
    alias hd_b : std_logic_vector (11 downto 0)
	is hd_code (31 downto 20);
    alias hd_g2 : std_logic_vector (11 downto 0)
	is hd_code (15 downto 4);


    --------------------------------------------------------------------
    -- HDMI Scan Signals
    --------------------------------------------------------------------

    signal scan_disp : std_logic_vector (3 downto 0);
    signal scan_sync : std_logic_vector (3 downto 0);
    signal scan_data : std_logic_vector (3 downto 0);
    signal scan_ctrl : std_logic_vector (3 downto 0);

    signal scan_hevent : std_logic_vector (3 downto 0);
    signal scan_vevent : std_logic_vector (3 downto 0);

    signal scan_hcnt : std_logic_vector (11 downto 0);
    signal scan_vcnt : std_logic_vector (11 downto 0);
    signal scan_fcnt : std_logic_vector (11 downto 0);

    signal scan_econf : std_logic_vector (63 downto 0);
    signal scan_event : std_logic_vector (63 downto 0);

    signal scan_eo : std_logic;

    signal scan_rblock : std_logic;
    signal scan_rreset : std_logic;
    signal scan_rload : std_logic;
    signal scan_arm : std_logic;

    signal sync_rblock : std_logic;
    signal sync_rreset : std_logic;
    signal sync_rload : std_logic;
    signal sync_rswitch : std_logic_vector (1 downto 0);

    signal event_event : std_logic_vector (7 downto 0);
    signal event_data : std_logic_vector (1 downto 0);
    signal event_data_d : std_logic_vector (1 downto 0);

    signal event_hcnt : std_logic_vector (11 downto 0);
    signal event_vcnt : std_logic_vector (11 downto 0);
    signal event_fcnt : std_logic_vector (11 downto 0);

    signal event_cr : std_logic_vector (11 downto 0);
    signal event_cg : std_logic_vector (11 downto 0);
    signal event_cb : std_logic_vector (11 downto 0);




    --------------------------------------------------------------------
    -- Capture Sequencer Signals
    --------------------------------------------------------------------

    signal cseq_clk : std_logic;
    signal cseq_done : std_logic;
    signal cseq_fcnt : std_logic_vector (11 downto 0)
	:= (others => '0');

    signal cseq_req : std_logic;
    signal cseq_shift : std_logic_vector (31 downto 0)
	:= (others => '0');

    signal cseq_wblock : std_logic;
    signal cseq_wreset : std_logic;
    signal cseq_wload : std_logic;
    signal cseq_wswitch : std_logic;

    signal cseq_wempty : std_logic;
    signal cseq_frmreq : std_logic;

    signal cseq_flip : std_logic;
    signal cseq_switch : std_logic;

    signal sync_wblock : std_logic;
    signal sync_wreset : std_logic;
    signal sync_wload : std_logic;
    signal sync_wswitch : std_logic_vector (1 downto 0);

    signal sync_wempty : std_logic;
    signal sync_wenable : std_logic;
    signal sync_winact : std_logic;
    signal sync_frmreq : std_logic;
    signal sync_arm : std_logic;

    --------------------------------------------------------------------
    -- Cross Event Signals
    --------------------------------------------------------------------

    signal cmv_active : std_logic;

    signal sync_switch : std_logic;
    signal sync_done : std_logic;

    signal flip_active : std_logic;

    signal sync_flip : std_logic;

    signal ilu_clk : std_logic;
    signal ilu_frmreq : std_logic;

    signal ilu_led0 : std_logic := '0';
    signal ilu_led1 : std_logic := '0';
    signal ilu_led2 : std_logic := '0';

    signal ilu_led3 : std_logic := '0';
    signal ilu_led4 : std_logic := '0';

    --------------------------------------------------------------------
    -- BRAM LUT Signals
    --------------------------------------------------------------------

    constant CLUT_COUNT : natural := 6;

    signal clut_addr : lut11_a (0 to CLUT_COUNT - 1);
    signal clut_dout : lut12_a (0 to CLUT_COUNT - 1);
    signal clut_dout_d : lut12_a (0 to CLUT_COUNT - 1);
    signal clut_dout_dd : lut12_a (0 to CLUT_COUNT - 1);

    constant LLUT_COUNT : natural := 4;

    signal llut_addr : lut12_a (0 to LLUT_COUNT - 1);
    signal llut_dout : lut18_a (0 to LLUT_COUNT - 1);
    signal llut_dout_d : lut18_a (0 to LLUT_COUNT - 1);

    constant DLUT_COUNT : natural := 4;

    signal dlut_addr : lut12_a (0 to DLUT_COUNT - 1);
    signal dlut_dout : lut16_a (0 to DLUT_COUNT - 1);
    signal dlut_dout_d : lut16_a (0 to DLUT_COUNT - 1);

    --------------------------------------------------------------------
    -- BRAM MEM Signals
    --------------------------------------------------------------------

    signal dmem_addr : std_logic_vector (11 downto 0);
    signal dmem_dout : std_logic_vector (8 downto 0);

begin

    --------------------------------------------------------------------
    -- PS7 Interface
    --------------------------------------------------------------------

    ps7_stub_inst : entity work.ps7_stub
	port map (
	    i2c0_sda_i => i2c0_sda_i,
	    i2c0_sda_o => i2c0_sda_o,
	    i2c0_sda_t_n => i2c0_sda_t_n,
	    --
	    i2c0_scl_i => i2c0_scl_i,
	    i2c0_scl_o => i2c0_scl_o,
	    i2c0_scl_t_n => i2c0_scl_t_n,
	    --
	    i2c1_sda_i => i2c1_sda_i,
	    i2c1_sda_o => i2c1_sda_o,
	    i2c1_sda_t_n => i2c1_sda_t_n,
	    --
	    i2c1_scl_i => i2c1_scl_i,
	    i2c1_scl_o => i2c1_scl_o,
	    i2c1_scl_t_n => i2c1_scl_t_n,
	    --
	    ps_fclk => ps_fclk,
	    ps_reset_n => ps_reset_n,
	    --
	    emio_gpio_i => emio_gpio_i,
	    emio_gpio_o => emio_gpio_o,
	    emio_gpio_t_n => emio_gpio_t_n,
	    --
	    m_axi0_aclk => m_axi0_aclk,
	    m_axi0_areset_n => m_axi0_areset_n,
	    --
	    m_axi0_arid => m_axi0_ro.arid,
	    m_axi0_araddr => m_axi0_ro.araddr,
	    m_axi0_arburst => m_axi0_ro.arburst,
	    m_axi0_arlen => m_axi0_ro.arlen,
	    m_axi0_arsize => m_axi0_ro.arsize,
	    m_axi0_arprot => m_axi0_ro.arprot,
	    m_axi0_arvalid => m_axi0_ro.arvalid,
	    m_axi0_arready => m_axi0_ri.arready,
	    --
	    m_axi0_rid => m_axi0_ri.rid,
	    m_axi0_rdata => m_axi0_ri.rdata,
	    m_axi0_rlast => m_axi0_ri.rlast,
	    m_axi0_rresp => m_axi0_ri.rresp,
	    m_axi0_rvalid => m_axi0_ri.rvalid,
	    m_axi0_rready => m_axi0_ro.rready,
	    --
	    m_axi0_awid => m_axi0_wo.awid,
	    m_axi0_awaddr => m_axi0_wo.awaddr,
	    m_axi0_awburst => m_axi0_wo.awburst,
	    m_axi0_awlen => m_axi0_wo.awlen,
	    m_axi0_awsize => m_axi0_wo.awsize,
	    m_axi0_awprot => m_axi0_wo.awprot,
	    m_axi0_awvalid => m_axi0_wo.awvalid,
	    m_axi0_awready => m_axi0_wi.wready,
	    --
	    m_axi0_wid => m_axi0_wo.wid,
	    m_axi0_wdata => m_axi0_wo.wdata,
	    m_axi0_wstrb => m_axi0_wo.wstrb,
	    m_axi0_wlast => m_axi0_wo.wlast,
	    m_axi0_wvalid => m_axi0_wo.wvalid,
	    m_axi0_wready => m_axi0_wi.wready,
	    --
	    m_axi0_bid => m_axi0_wi.bid,
	    m_axi0_bresp => m_axi0_wi.bresp,
	    m_axi0_bvalid => m_axi0_wi.bvalid,
	    m_axi0_bready => m_axi0_wo.bready,
	    --
	    m_axi1_aclk => m_axi1_aclk,
	    m_axi1_areset_n => m_axi1_areset_n,
	    --
	    m_axi1_arid => m_axi1_ro.arid,
	    m_axi1_araddr => m_axi1_ro.araddr,
	    m_axi1_arburst => m_axi1_ro.arburst,
	    m_axi1_arlen => m_axi1_ro.arlen,
	    m_axi1_arsize => m_axi1_ro.arsize,
	    m_axi1_arprot => m_axi1_ro.arprot,
	    m_axi1_arvalid => m_axi1_ro.arvalid,
	    m_axi1_arready => m_axi1_ri.arready,
	    --
	    m_axi1_rid => m_axi1_ri.rid,
	    m_axi1_rdata => m_axi1_ri.rdata,
	    m_axi1_rlast => m_axi1_ri.rlast,
	    m_axi1_rresp => m_axi1_ri.rresp,
	    m_axi1_rvalid => m_axi1_ri.rvalid,
	    m_axi1_rready => m_axi1_ro.rready,
	    --
	    m_axi1_awid => m_axi1_wo.awid,
	    m_axi1_awaddr => m_axi1_wo.awaddr,
	    m_axi1_awburst => m_axi1_wo.awburst,
	    m_axi1_awlen => m_axi1_wo.awlen,
	    m_axi1_awsize => m_axi1_wo.awsize,
	    m_axi1_awprot => m_axi1_wo.awprot,
	    m_axi1_awvalid => m_axi1_wo.awvalid,
	    m_axi1_awready => m_axi1_wi.wready,
	    --
	    m_axi1_wid => m_axi1_wo.wid,
	    m_axi1_wdata => m_axi1_wo.wdata,
	    m_axi1_wstrb => m_axi1_wo.wstrb,
	    m_axi1_wlast => m_axi1_wo.wlast,
	    m_axi1_wvalid => m_axi1_wo.wvalid,
	    m_axi1_wready => m_axi1_wi.wready,
	    --
	    m_axi1_bid => m_axi1_wi.bid,
	    m_axi1_bresp => m_axi1_wi.bresp,
	    m_axi1_bvalid => m_axi1_wi.bvalid,
	    m_axi1_bready => m_axi1_wo.bready,
	    --
	    s_axi0_aclk => s_axi_aclk(0),
	    s_axi0_areset_n => s_axi_areset_n(0),
	    --
	    s_axi0_arid => s_axi_ri(0).arid,
	    s_axi0_araddr => s_axi_ri(0).araddr,
	    s_axi0_arburst => s_axi_ri(0).arburst,
	    s_axi0_arlen => s_axi_ri(0).arlen,
	    s_axi0_arsize => s_axi_ri(0).arsize,
	    s_axi0_arprot => s_axi_ri(0).arprot,
	    s_axi0_arvalid => s_axi_ri(0).arvalid,
	    s_axi0_arready => s_axi_ro(0).arready,
	    s_axi0_racount => s_axi_ro(0).racount,
	    --
	    s_axi0_rid => s_axi_ro(0).rid,
	    s_axi0_rdata => s_axi_ro(0).rdata,
	    s_axi0_rlast => s_axi_ro(0).rlast,
	    s_axi0_rvalid => s_axi_ro(0).rvalid,
	    s_axi0_rready => s_axi_ri(0).rready,
	    s_axi0_rcount => s_axi_ro(0).rcount,
	    --
	    s_axi0_awid => s_axi_wi(0).awid,
	    s_axi0_awaddr => s_axi_wi(0).awaddr,
	    s_axi0_awburst => s_axi_wi(0).awburst,
	    s_axi0_awlen => s_axi_wi(0).awlen,
	    s_axi0_awsize => s_axi_wi(0).awsize,
	    s_axi0_awprot => s_axi_wi(0).awprot,
	    s_axi0_awvalid => s_axi_wi(0).awvalid,
	    s_axi0_awready => s_axi_wo(0).awready,
	    s_axi0_wacount => s_axi_wo(0).wacount,
	    --
	    s_axi0_wid => s_axi_wi(0).wid,
	    s_axi0_wdata => s_axi_wi(0).wdata,
	    s_axi0_wstrb => s_axi_wi(0).wstrb,
	    s_axi0_wlast => s_axi_wi(0).wlast,
	    s_axi0_wvalid => s_axi_wi(0).wvalid,
	    s_axi0_wready => s_axi_wo(0).wready,
	    s_axi0_wcount => s_axi_wo(0).wcount,
	    --
	    s_axi0_bid => s_axi_wo(0).bid,
	    s_axi0_bresp => s_axi_wo(0).bresp,
	    s_axi0_bvalid => s_axi_wo(0).bvalid,
	    s_axi0_bready => s_axi_wi(0).bready,
	    --
	    s_axi1_aclk => s_axi_aclk(1),
	    s_axi1_areset_n => s_axi_areset_n(1),
	    --
	    s_axi1_arid => s_axi_ri(1).arid,
	    s_axi1_araddr => s_axi_ri(1).araddr,
	    s_axi1_arburst => s_axi_ri(1).arburst,
	    s_axi1_arlen => s_axi_ri(1).arlen,
	    s_axi1_arsize => s_axi_ri(1).arsize,
	    s_axi1_arprot => s_axi_ri(1).arprot,
	    s_axi1_arvalid => s_axi_ri(1).arvalid,
	    s_axi1_arready => s_axi_ro(1).arready,
	    s_axi1_racount => s_axi_ro(1).racount,
	    --
	    s_axi1_rid => s_axi_ro(1).rid,
	    s_axi1_rdata => s_axi_ro(1).rdata,
	    s_axi1_rlast => s_axi_ro(1).rlast,
	    s_axi1_rvalid => s_axi_ro(1).rvalid,
	    s_axi1_rready => s_axi_ri(1).rready,
	    s_axi1_rcount => s_axi_ro(1).rcount,
	    --
	    s_axi1_awid => s_axi_wi(1).awid,
	    s_axi1_awaddr => s_axi_wi(1).awaddr,
	    s_axi1_awburst => s_axi_wi(1).awburst,
	    s_axi1_awlen => s_axi_wi(1).awlen,
	    s_axi1_awsize => s_axi_wi(1).awsize,
	    s_axi1_awprot => s_axi_wi(1).awprot,
	    s_axi1_awvalid => s_axi_wi(1).awvalid,
	    s_axi1_awready => s_axi_wo(1).awready,
	    s_axi1_wacount => s_axi_wo(1).wacount,
	    --
	    s_axi1_wid => s_axi_wi(1).wid,
	    s_axi1_wdata => s_axi_wi(1).wdata,
	    s_axi1_wstrb => s_axi_wi(1).wstrb,
	    s_axi1_wlast => s_axi_wi(1).wlast,
	    s_axi1_wvalid => s_axi_wi(1).wvalid,
	    s_axi1_wready => s_axi_wo(1).wready,
	    s_axi1_wcount => s_axi_wo(1).wcount,
	    --
	    s_axi1_bid => s_axi_wo(1).bid,
	    s_axi1_bresp => s_axi_wo(1).bresp,
	    s_axi1_bvalid => s_axi_wo(1).bvalid,
	    s_axi1_bready => s_axi_wi(1).bready,
	    --
	    s_axi2_aclk => s_axi_aclk(2),
	    s_axi2_areset_n => s_axi_areset_n(2),
	    --
	    s_axi2_arid => s_axi_ri(2).arid,
	    s_axi2_araddr => s_axi_ri(2).araddr,
	    s_axi2_arburst => s_axi_ri(2).arburst,
	    s_axi2_arlen => s_axi_ri(2).arlen,
	    s_axi2_arsize => s_axi_ri(2).arsize,
	    s_axi2_arprot => s_axi_ri(2).arprot,
	    s_axi2_arvalid => s_axi_ri(2).arvalid,
	    s_axi2_arready => s_axi_ro(2).arready,
	    s_axi2_racount => s_axi_ro(2).racount,
	    --
	    s_axi2_rid => s_axi_ro(2).rid,
	    s_axi2_rdata => s_axi_ro(2).rdata,
	    s_axi2_rlast => s_axi_ro(2).rlast,
	    s_axi2_rvalid => s_axi_ro(2).rvalid,
	    s_axi2_rready => s_axi_ri(2).rready,
	    s_axi2_rcount => s_axi_ro(2).rcount,
	    --
	    s_axi2_awid => s_axi_wi(2).awid,
	    s_axi2_awaddr => s_axi_wi(2).awaddr,
	    s_axi2_awburst => s_axi_wi(2).awburst,
	    s_axi2_awlen => s_axi_wi(2).awlen,
	    s_axi2_awsize => s_axi_wi(2).awsize,
	    s_axi2_awprot => s_axi_wi(2).awprot,
	    s_axi2_awvalid => s_axi_wi(2).awvalid,
	    s_axi2_awready => s_axi_wo(2).awready,
	    s_axi2_wacount => s_axi_wo(2).wacount,
	    --
	    s_axi2_wid => s_axi_wi(2).wid,
	    s_axi2_wdata => s_axi_wi(2).wdata,
	    s_axi2_wstrb => s_axi_wi(2).wstrb,
	    s_axi2_wlast => s_axi_wi(2).wlast,
	    s_axi2_wvalid => s_axi_wi(2).wvalid,
	    s_axi2_wready => s_axi_wo(2).wready,
	    s_axi2_wcount => s_axi_wo(2).wcount,
	    --
	    s_axi2_bid => s_axi_wo(2).bid,
	    s_axi2_bresp => s_axi_wo(2).bresp,
	    s_axi2_bvalid => s_axi_wo(2).bvalid,
	    s_axi2_bready => s_axi_wi(2).bready,
	    --
	    s_axi3_aclk => s_axi_aclk(3),
	    s_axi3_areset_n => s_axi_areset_n(3),
	    --
	    s_axi3_arid => s_axi_ri(3).arid,
	    s_axi3_araddr => s_axi_ri(3).araddr,
	    s_axi3_arburst => s_axi_ri(3).arburst,
	    s_axi3_arlen => s_axi_ri(3).arlen,
	    s_axi3_arsize => s_axi_ri(3).arsize,
	    s_axi3_arprot => s_axi_ri(3).arprot,
	    s_axi3_arvalid => s_axi_ri(3).arvalid,
	    s_axi3_arready => s_axi_ro(3).arready,
	    s_axi3_racount => s_axi_ro(3).racount,
	    --
	    s_axi3_rid => s_axi_ro(3).rid,
	    s_axi3_rdata => s_axi_ro(3).rdata,
	    s_axi3_rlast => s_axi_ro(3).rlast,
	    s_axi3_rvalid => s_axi_ro(3).rvalid,
	    s_axi3_rready => s_axi_ri(3).rready,
	    s_axi3_rcount => s_axi_ro(3).rcount,
	    --
	    s_axi3_awid => s_axi_wi(3).awid,
	    s_axi3_awaddr => s_axi_wi(3).awaddr,
	    s_axi3_awburst => s_axi_wi(3).awburst,
	    s_axi3_awlen => s_axi_wi(3).awlen,
	    s_axi3_awsize => s_axi_wi(3).awsize,
	    s_axi3_awprot => s_axi_wi(3).awprot,
	    s_axi3_awvalid => s_axi_wi(3).awvalid,
	    s_axi3_awready => s_axi_wo(3).awready,
	    s_axi3_wacount => s_axi_wo(3).wacount,
	    --
	    s_axi3_wid => s_axi_wi(3).wid,
	    s_axi3_wdata => s_axi_wi(3).wdata,
	    s_axi3_wstrb => s_axi_wi(3).wstrb,
	    s_axi3_wlast => s_axi_wi(3).wlast,
	    s_axi3_wvalid => s_axi_wi(3).wvalid,
	    s_axi3_wready => s_axi_wo(3).wready,
	    s_axi3_wcount => s_axi_wo(3).wcount,
	    --
	    s_axi3_bid => s_axi_wo(3).bid,
	    s_axi3_bresp => s_axi_wo(3).bresp,
	    s_axi3_bvalid => s_axi_wo(3).bvalid,
	    s_axi3_bready => s_axi_wi(3).bready );


    clk_100 <= ps_fclk(0);

    -- cmv_sys_res_n <= '1';

    --------------------------------------------------------------------
    -- I2C Interface AB
    --------------------------------------------------------------------

    i2c1_sda_t <= not i2c1_sda_t_n;

    IOBUF_sda_inst : IOBUF
	port map (
	    I => i2c1_sda_o, O => i2c1_sda_i,
	    T => i2c1_sda_t, IO => i2c_sda );

    i2c1_scl_t <= not i2c1_scl_t_n;

    PULLUP_sda_inst : PULLUP
        port map ( O => i2c_sda );

    IOBUF_scl_inst : IOBUF
	port map (
	    I => i2c1_scl_o, O => i2c1_scl_i,
	    T => i2c1_scl_t, IO => i2c_scl );

    PULLUP_scl_inst : PULLUP
        port map ( O => i2c_scl );

    --------------------------------------------------------------------
    -- CMV/LVDS/HDMI MMCM/PLL
    --------------------------------------------------------------------

    cmv_pll_inst : entity work.cmv_pll (RTL_250MHZ)
	port map (
	    ref_clk_in => clk_100,
	    --
	    pll_locked => cmv_pll_locked,
	    --
	    lvds_clk => cmv_lvds_clk,
	    dly_clk => cmv_dly_clk,
	    cmv_clk => cmv_cmd_clk,
	    spi_clk => cmv_spi_clk,
	    axi_clk => cmv_axi_clk );

    cmv_clk <= cmv_cmd_clk;

    lvds_pll_inst : entity work.lvds_pll (RTL_250MHZ)
	port map (
	    ref_clk_in => cmv_outclk,
	    --
	    pll_locked => lvds_pll_locked,
	    --
	    lvds_clk => lvds_clk,
	    word_clk => word_clk );

    hdmi_pll_inst : entity work.hdmi_pll
	generic map (
	    -- PLL_CONFIG => HDMI_7425KHZ )
	    -- PLL_CONFIG => HDMI_5000KHZ )
	    PLL_CONFIG => HDMI_148500KHZ )
	port map (
	    ref_clk_in => clk_100,
	    --
	    pll_locked => hdmi_pll_locked,
	    pll_pwrdwn => hdmi_pll_pwrdwn,
	    pll_reset => hdmi_pll_reset,
	    --
	    tmds_clk => tmds_clk,
	    hdmi_clk => hdmi_clk,
	    data_clk => data_clk,
	    --
	    s_axi_aclk => m_axi1a_aclk(4),
	    s_axi_areset_n => m_axi1a_areset_n(4),
	    --
	    s_axi_ro => m_axi1a_ri(4),
	    s_axi_ri => m_axi1a_ro(4),
	    s_axi_wo => m_axi1a_wi(4),
	    s_axi_wi => m_axi1a_wo(4) );

    --------------------------------------------------------------------
    -- AXI3 CMV Interconnect
    --------------------------------------------------------------------

    axi_lite_inst0 : entity work.axi_lite
	port map (
	    s_axi_aclk => m_axi0_aclk,
	    s_axi_areset_n => m_axi0_areset_n,

	    s_axi_ro => m_axi0_ri,
	    s_axi_ri => m_axi0_ro,
	    s_axi_wo => m_axi0_wi,
	    s_axi_wi => m_axi0_wo,

	    m_axi_ro => m_axi0l_ro,
	    m_axi_ri => m_axi0l_ri,
	    m_axi_wo => m_axi0l_wo,
	    m_axi_wi => m_axi0l_wi );

    m_axi0_aclk <= clk_100;

    axi_split_inst0 : entity work.axi_split8
	generic map (
	    SPLIT_BIT0 => 20,
	    SPLIT_BIT1 => 21,
	    SPLIT_BIT2 => 22 )
	port map (
	    s_axi_aclk => m_axi0_aclk,
	    s_axi_areset_n => m_axi0_areset_n,
	    --
	    s_axi_ro => m_axi0l_ri,
	    s_axi_ri => m_axi0l_ro,
	    s_axi_wo => m_axi0l_wi,
	    s_axi_wi => m_axi0l_wo,
	    --
	    m_axi_aclk => m_axi0a_aclk,
	    m_axi_areset_n => m_axi0a_areset_n,
	    --
	    m_axi_ri => m_axi0a_ri,
	    m_axi_ro => m_axi0a_ro,
	    m_axi_wi => m_axi0a_wi,
	    m_axi_wo => m_axi0a_wo );

    --------------------------------------------------------------------
    -- CMV SPI Interface
    --------------------------------------------------------------------

    reg_spi_inst : entity work.reg_spi
	port map (
	    s_axi_aclk => m_axi0a_aclk(0),
	    s_axi_areset_n => m_axi0a_areset_n(0),
	    --
	    s_axi_ro => m_axi0a_ri(0),
	    s_axi_ri => m_axi0a_ro(0),
	    s_axi_wo => m_axi0a_wi(0),
	    s_axi_wi => m_axi0a_wo(0),
	    --
	    spi_clk_in => cmv_spi_clk,
	    --
	    spi_clk => spi_clk,
	    spi_in => spi_in,
	    spi_out => spi_out,
	    spi_en => spi_en );


    --------------------------------------------------------------------
    -- Capture Register File
    --------------------------------------------------------------------

    reg_file_inst0 : entity work.reg_file
	generic map (
	    REG_SPLIT => REG_SPLIT,
	    OREG_SIZE => OREG_SIZE,
	    IREG_SIZE => IREG_SIZE )
	port map (
	    s_axi_aclk => m_axi0a_aclk(1),
	    s_axi_areset_n => m_axi0a_areset_n(1),
	    --
	    s_axi_ro => m_axi0a_ri(1),
	    s_axi_ri => m_axi0a_ro(1),
	    s_axi_wo => m_axi0a_wi(1),
	    s_axi_wi => m_axi0a_wo(1),
	    --
	    oreg => reg_oreg,
	    ireg => reg_ireg );

    reg_ireg(0) <= x"524547" & x"0" &
		   std_logic_vector(to_unsigned(REG_SPLIT, 4));
    reg_ireg(1) <= usr_access;
    reg_ireg(2) <= par_match(31 downto 0);
    reg_ireg(3) <= par_mismatch(31 downto 0);
    reg_ireg(4) <= waddr_in(31 downto 0);
    reg_ireg(5) <= waddr_sel & "00" & writer_inactive &		-- 8bit
		   "00" & fifo_data_wrerr & fifo_data_rderr &	-- 4bit
		   fifo_data_full & fifo_data_high &		-- 2bit
		   fifo_data_low & fifo_data_empty &		-- 2bit
		   "000" & btn & swi;				-- 16bit
    reg_ireg(6) <= cseq_done & "000" & cseq_fcnt & 		-- 16bit
		   par_match(32) & par_mismatch(32) & "00" &	-- 4bit
		   par_data(32);
    reg_ireg(7) <= cseq_wblock & cseq_wreset & 			-- 2bit
		   cseq_wload & cseq_wswitch &			-- 2bit
		   cseq_wempty & cseq_frmreq &			-- 2bit
		   cseq_flip & cseq_switch & x"000000";		-- 18bit
		   

    --------------------------------------------------------------------
    -- Delay Control
    --------------------------------------------------------------------

    IDELAYCTRL_inst : IDELAYCTRL
	port map (
	    RDY => idelay_valid,	-- 1-bit output indicates validity of the REFCLK
	    REFCLK => cmv_dly_clk,	-- 1-bit reference clock input
	    RST => '0' );		-- 1-bit reset input

    --------------------------------------------------------------------
    -- Delay Register File
    --------------------------------------------------------------------

    reg_delay_inst : entity work.reg_delay
	generic map (
	    REG_BASE => 16#60000000#,
	    CHANNELS => CHANNELS + 2 )
	port map (
	    s_axi_aclk => m_axi0a_aclk(2),
	    s_axi_areset_n => m_axi0a_areset_n(2),
	    --
	    s_axi_ro => m_axi0a_ri(2),
	    s_axi_ri => m_axi0a_ro(2),
	    s_axi_wo => m_axi0a_wi(2),
	    s_axi_wi => m_axi0a_wo(2),
	    --
	    delay_clk => serdes_clkdiv,		-- in
	    --
	    delay_in => idelay_in,		-- in
	    delay_out => idelay_out,		-- out
	    --
	    match => par_match,			-- in
	    mismatch => par_mismatch,		-- in
	    bitslip => serdes_bitslip );	-- out

    --------------------------------------------------------------------
    -- BRAM LUT Register File (Linearization)
    --------------------------------------------------------------------

    reg_lut_inst2 : entity work.reg_lut_12x18
	generic map (
	    LUT_COUNT => LLUT_COUNT )
	port map (
	    s_axi_aclk => m_axi0a_aclk(5),
	    s_axi_areset_n => m_axi0a_areset_n(5),
	    --
	    s_axi_ro => m_axi0a_ri(5),
	    s_axi_ri => m_axi0a_ro(5),
	    s_axi_wo => m_axi0a_wi(5),
	    s_axi_wi => m_axi0a_wo(5),
	    --
	    lut_clk => fifo_data_wclk,
	    lut_addr => llut_addr,
	    lut_dout => llut_dout );

    --------------------------------------------------------------------
    -- BRAM LUT Register File (ColRow Noise)
    --------------------------------------------------------------------

    reg_lut_inst0 : entity work.reg_lut_11x12
	generic map (
	    LUT_COUNT => CLUT_COUNT )
	port map (
	    s_axi_aclk => m_axi0a_aclk(3),
	    s_axi_areset_n => m_axi0a_areset_n(3),
	    --
	    s_axi_ro => m_axi0a_ri(3),
	    s_axi_ri => m_axi0a_ro(3),
	    s_axi_wo => m_axi0a_wi(3),
	    s_axi_wi => m_axi0a_wo(3),
	    --
	    lut_clk => serdes_clk,
	    lut_addr => clut_addr,
	    lut_dout => clut_dout );

    --------------------------------------------------------------------
    -- LVDS Input and Deserializer
    --------------------------------------------------------------------

    OBUFDS_inst : OBUFDS
	generic map (
	    IOSTANDARD => "LVDS_25",
	    SLEW => "SLOW" )
	port map (
	    O => cmv_lvds_clk_p,
	    OB => cmv_lvds_clk_n,
	    I => cmv_lvds_clk );

    IBUFDS_inst : IBUFGDS_DIFF_OUT
	generic map (
	    DIFF_TERM => TRUE,
	    IBUF_LOW_PWR => TRUE,
	    IOSTANDARD => "LVDS_25" )
	port map (
	    O => idelay_in_p(CHANNELS + 1),
	    OB => idelay_in_n(CHANNELS + 1),
	    I => cmv_lvds_outclk_p,
	    IB => cmv_lvds_outclk_n );

    GEN_LVDS: for I in CHANNELS downto 0 generate
    begin

	CTRL : if I = CHANNELS generate
	    IBUFDS_i : IBUFDS_DIFF_OUT
		generic map (
		    DIFF_TERM => TRUE,
		    IBUF_LOW_PWR => TRUE,
		    IOSTANDARD => "LVDS_25" )
		port map (
		    O => idelay_in_p(I),
		    OB => idelay_in_n(I),
		    I => cmv_lvds_ctrl_p,
		    IB => cmv_lvds_ctrl_n );

	end generate;

	DATA : if I < CHANNELS generate
	    IBUFDS_i : IBUFDS_DIFF_OUT
		generic map (
		    DIFF_TERM => TRUE,
		    IBUF_LOW_PWR => TRUE,
		    IOSTANDARD => "LVDS_25" )
		port map (
		    O => idelay_in_p(I),
		    OB => idelay_in_n(I),
		    I => cmv_lvds_data_p(I),
		    IB => cmv_lvds_data_n(I) );

	end generate;

--	div_cmv_inst : entity work.async_div
--	    generic map (
--		STAGES => 28 )
--	    port map (
--		clk_in => ser_out(I),
--		clk_out => div_out(I) );

    end generate;

--  idelay_in <= idelay_in_p;
    idelay_in(17 downto 0) <= idelay_in_p(17 downto 0);
    idelay_in(18) <= idelay_in_n(18);
    idelay_in(CHANNELS downto 19) <= idelay_in_p(CHANNELS downto 19);
    idelay_in(CHANNELS + 1) <= idelay_in_n(CHANNELS + 1);

    cmv_outclk <= not idelay_out(CHANNELS + 1);

    ser_to_par_inst : entity work.ser_to_par
	generic map (
	    CHANNELS => CHANNELS + 1 )
	port map (
	    serdes_clk	  => serdes_clk,	-- in
	    serdes_clkdiv => serdes_clkdiv,	-- in
	    serdes_phase  => serdes_phase,	-- in
	    serdes_rst	  => serdes_reset,	-- in
	    --
	    ser_data	  => idelay_out(CHANNELS downto 0),
	    --
	    par_clk	  => serdes_clk,	-- in
	    par_enable	  => par_enable,	-- out
	    par_data	  => par_data,		-- out
	    --
	    bitslip	  => serdes_bitslip(CHANNELS downto 0) );

    phase_proc : process (serdes_clkdiv)
	variable phase_v : std_logic := '0';
    begin
	serdes_phase <= phase_v;

	if rising_edge(serdes_clkdiv) then
	    if serdes_bitslip(CHANNELS + 1) = '0' then
		phase_v := not phase_v;
	    end if;
	end if;
    end process;

    par_match_inst : entity work.par_match
	generic map (
	    CHANNELS => CHANNELS + 1 )
	port map (
	    par_clk	=> serdes_clkdiv,	-- in
	    par_data	=> par_data,		-- in
	    --
	    pattern	=> par_pattern,		-- in
	    --
	    match	=> par_match(CHANNELS downto 0),
	    mismatch	=> par_mismatch(CHANNELS downto 0) );


    GEN_PAT: for I in CHANNELS - 1 downto 0 generate
	par_pattern(I) <= reg_pattern;
    end generate;

    par_pattern(CHANNELS) <= x"080";

    --------------------------------------------------------------------
    -- Address Generator
    --------------------------------------------------------------------

    waddr_gen_inst : entity work.addr_qbuf
	port map (
	    clk => waddr_clk,
	    reset => waddr_reset,
	    load => waddr_load,
	    enable => waddr_enable,
	    --
	    sel_in => waddr_sel_in,
	    switch => waddr_switch,
	    --
	    buf0_addr => waddr_buf0,
	    buf1_addr => waddr_buf1,
	    buf2_addr => waddr_buf2,
	    buf3_addr => waddr_buf3,
	    --
	    col_inc => waddr_cinc,
	    col_cnt => waddr_ccnt,
	    --
	    row_inc => waddr_rinc,
	    --
	    buf0_epat => waddr_pat0,
	    buf1_epat => waddr_pat1,
	    buf2_epat => waddr_pat2,
	    buf3_epat => waddr_pat3,
	    --
	    addr => waddr_in,
	    match => waddr_match,
	    sel => waddr_sel );

    waddr_empty <= waddr_match or waddr_block;

    --------------------------------------------------------------------
    -- Data FIFO
    --------------------------------------------------------------------

    FIFO_data_inst : FIFO_DUALCLOCK_MACRO
	generic map (
	    DEVICE => "7SERIES",
	    DATA_WIDTH => DATA_WIDTH,
	    ALMOST_FULL_OFFSET => x"020",
	    ALMOST_EMPTY_OFFSET => x"020",
	    FIFO_SIZE => "36Kb",
	    FIRST_WORD_FALL_THROUGH => TRUE )
	port map (
	    DI => fifo_data_in,
	    WRCLK => fifo_data_wclk,
	    WREN => fifo_data_wen,
	    FULL => fifo_data_full,
	    ALMOSTFULL => fifo_data_high,
	    WRERR => fifo_data_wrerr,
	    WRCOUNT => fifo_data_wrcount,
	    --
	    DO => fifo_data_out,
	    RDCLK => fifo_data_rclk,
	    RDEN => fifo_data_ren,
	    EMPTY => fifo_data_empty,
	    ALMOSTEMPTY => fifo_data_low,
	    RDERR => fifo_data_rderr,
	    RDCOUNT => fifo_data_rdcount,
	    --
	    RST => fifo_data_rst );

    fifo_reset_inst0 : entity work.fifo_reset
	port map (
	    rclk => fifo_data_rclk,
	    wclk => fifo_data_wclk,
	    reset => fifo_data_reset,
	    --
	    fifo_rst => fifo_data_rst,
	    fifo_rrdy => fifo_data_rrdy,
	    fifo_wrdy => fifo_data_wrdy );


    conf_delay_proc : process (serdes_clkdiv)
	type del_a is array (natural range <>) of
	    std_logic_vector (12 downto 0);
	type dat_a is array (natural range <>) of
	    par12_a (CHANNELS downto 0);

	variable del_v : del_a (15 downto 0)
	    := (others => (others => '0'));
	variable dat_v : dat_a (15 downto 0)
	    := (others => (others => (others => '0')));

	variable cpos_v : integer;
	variable vpos_v : integer;
	variable epos_v : integer;
	variable opos_v : integer;

    begin
	if rising_edge(serdes_clkdiv) then
	    par_valid_d <= del_v(vpos_v)(12);
	    par_ctrl_d <= del_v(cpos_v)(11 downto 0);
	    par_data_e <= dat_v(epos_v);
	    par_data_o <= dat_v(opos_v);

	    cpos_v := to_index(reg_oreg(14)(31 downto 28));
	    vpos_v := to_index(reg_oreg(14)(27 downto 24));
	    epos_v := to_index(reg_oreg(14)(23 downto 20));
	    opos_v := to_index(reg_oreg(14)(19 downto 16));

            for I in 15 downto 1 loop
		del_v(I) := del_v(I-1);
		dat_v(I) := dat_v(I-1);
	    end loop; 
	
	    del_v(0) := par_valid & par_ctrl;
	    dat_v(0) := par_data;
	end if;
    end process;

    pixel_remap_even_inst : entity work.pixel_remap
	  generic map (
	    NB_LANES => CHANNELS/2 )
	  port map (
	    clk	     => serdes_clkdiv,
	    --
	    dv_par   => par_valid_d,
	    ctrl_in  => par_ctrl_d,
	    par_din  => par_data_e(15 downto 0),
	    --
	    ctrl_out => map_ctrl,
	    par_dout => map_data(15 downto 0) );

    pixel_remap_odd_inst : entity work.pixel_remap
	  generic map (
	    NB_LANES => CHANNELS/2 )
	  port map (
	    clk	     => serdes_clkdiv,
	    --
	    dv_par   => par_valid_d,
	    ctrl_in  => par_ctrl_d,
	    par_din  => par_data_o(31 downto 16),
	    --
	    ctrl_out => open,
	    par_dout => map_data(31 downto 16) );

    valid_proc : process (serdes_clkdiv)
    begin
	if rising_edge(serdes_clkdiv) then
	    if serdes_phase = '1' then
		par_valid <= '1';
	    else
		par_valid <= '0';
	    end if;
	end if;
    end process;

    remap_proc : process (serdes_clkdiv)
    begin
	if rising_edge(serdes_clkdiv) then
	    remap_ctrl <= map_ctrl;
	    remap_data <=
		map_data(30 downto 30) & map_data(31 downto 31) &
		map_data(14 downto 14) & map_data(15 downto 15) &
		map_data(28 downto 28) & map_data(29 downto 29) &
		map_data(12 downto 12) & map_data(13 downto 13) &
		map_data(26 downto 26) & map_data(27 downto 27) &
		map_data(10 downto 10) & map_data(11 downto 11) &
		map_data(24 downto 24) & map_data(25 downto 25) &
		map_data( 8 downto  8) & map_data( 9 downto  9) &
		map_data(22 downto 22) & map_data(23 downto 23) &
		map_data( 6 downto  6) & map_data( 7 downto  7) &
		map_data(20 downto 20) & map_data(21 downto 21) &
		map_data( 4 downto  4) & map_data( 5 downto  5) &
		map_data(18 downto 18) & map_data(19 downto 19) &
		map_data( 2 downto  2) & map_data( 3 downto  3) &
		map_data(16 downto 16) & map_data(17 downto 17) &
		map_data( 0 downto  0) & map_data( 1 downto  1);
	end if;
    end process;

    fifo_chop_inst : entity work.fifo_chop (RTL_SHIFT)
	port map (
	    par_clk => serdes_clk,
	    par_enable => par_enable,
	    par_data => remap_data,
	    --
	    par_ctrl => remap_ctrl,
	    --
	    fifo_clk => fifo_data_wclk,
	    fifo_enable => data_wen(0),
	    fifo_data => data_in,
	    --
	    fifo_ctrl => data_ctrl );

    chop_proc : process (serdes_clk, serdes_clkdiv, par_valid)
	variable clkdiv_v : std_logic := '0';
    begin
	if rising_edge(serdes_clk) then
	    if serdes_clkdiv = '1' and clkdiv_v = '0' then
		chop_enable <= par_valid;
	    else
		chop_enable <= '0';
	    end if;

	    clkdiv_v := serdes_clkdiv;
	end if;
    end process;



    llut_proc : process (fifo_data_wclk)
    begin
	if rising_edge(fifo_data_wclk) then
	    llut_dout_ch0 <= llut_dout_d(0);
	    llut_dout_ch1 <= llut_dout_d(1);
	    llut_dout_ch2 <= llut_dout_d(2);
	    llut_dout_ch3 <= llut_dout_d(3);

	    llut_dout_d <= llut_dout;

	    llut_addr(0) <= data_in_d(63 downto 52);
	    llut_addr(1) <= data_in_d(51 downto 40);
	    llut_addr(2) <= data_in_d(39 downto 28);
	    llut_addr(3) <= data_in_d(27 downto 16);

	    data_in_d <= data_in;
	end if;
    end process;

--  delay_inst0 : entity work.sync_delay
--	generic map (
--	    STAGES => 2,
--	    DATA_WIDTH => data_in'length )
--	port map (
--	    clk => fifo_data_wclk,
--	    data_in => data_in,
--	    data_out => data_in_d );


    delay_inst0 : entity work.sync_delay
	generic map (
	    STAGES => 2,
	    DATA_WIDTH => data_ctrl'length )
	port map (
	    clk => fifo_data_wclk,
	    data_in => data_ctrl,
	    data_out => data_ctrl_d );

    delay_inst1 : entity work.sync_delay
	generic map (
	    STAGES => 3,
	    DATA_WIDTH => data_ctrl'length )
	port map (
	    clk => fifo_data_wclk,
	    data_in => data_ctrl_d,
	    data_out => data_ctrl_dd );

    delay_inst2 : entity work.sync_delay
	generic map (
	    STAGES => 2,
	    DATA_WIDTH => 1 )
	port map (
	    clk => fifo_data_wclk,
	    data_in => data_wen,
	    data_out => data_wen_d );

    delay_inst3 : entity work.sync_delay
	generic map (
	    STAGES => 4,
	    DATA_WIDTH => 1 )
	port map (
	    clk => fifo_data_wclk,
	    data_in => data_wen_d,
	    data_out => data_wen_dd );

/*  conf_delay_proc : process (fifo_data_wclk)
	type del_a is array (natural range <>) of
	    std_logic_vector (12 downto 0);

	variable del_v : del_a (15 downto 0)
	    := (others => (others => '0'));

	variable cpos_v : integer;
	variable cposd_v : integer;
	variable wpos_v : integer;
	variable wposd_v : integer;

    begin
	if rising_edge(fifo_data_wclk) then
	    data_wen_d <= del_v(wpos_v)(12 downto 12);
	    data_wen_dd <= del_v(wposd_v)(12 downto 12);
	    data_ctrl_d <= del_v(cpos_v)(11 downto 0);
	    data_ctrl_dd <= del_v(cposd_v)(11 downto 0);

	    cpos_v := to_index(reg_oreg(14)(31 downto 28));
	    cposd_v := to_index(reg_oreg(14)(27 downto 24));
	    wpos_v := to_index(reg_oreg(14)(23 downto 20));
	    wposd_v := to_index(reg_oreg(14)(19 downto 16));

            for I in 15 downto 1 loop
		del_v(I) := del_v(I-1);
	    end loop; 
	
	    del_v(0) := data_wen & data_ctrl;
	end if;
    end process; 	*/


    track_proc : process (fifo_data_wclk)
	variable lval_v : std_logic := '0';
	variable fval_v : std_logic := '0';

	variable ccnt_v : unsigned (10 downto 0) := (others => '0');
	variable rcnt_v : unsigned (10 downto 0) := (others => '0');

	variable ccnt_d_v : unsigned (ccnt_v'range) := (others => '0');
	variable rcnt_d_v : unsigned (rcnt_v'range) := (others => '0');

    begin

	if rising_edge(fifo_data_wclk) then
	    if fval_v = '1' and data_fval_d = '0' then
		ccnt_v := (others => '0');
		rcnt_v := (others => '0');
		
	    elsif lval_v = '1' and data_lval_d = '0' then
		ccnt_v := (others => '0');
		rcnt_v := rcnt_v + "1";

	    elsif data_dval_d = '1' and data_wen_d(0) = '1' then
		ccnt_v := ccnt_v + "1";

	    end if;

	--  clut_addr(0) <= data_fot & data_inte1 & data_inte2 &
	--	std_logic_vector(ccnt_v);
	--  clut_addr(1) <= data_fot & data_inte1 & data_inte2 &
	--	std_logic_vector(ccnt_v);

	    clut_dout_dd <= clut_dout_d;
	    clut_dout_d <= clut_dout;

	    clut_addr(0) <= std_logic_vector(ccnt_v);
	    clut_addr(1) <= std_logic_vector(ccnt_v);

	    clut_addr(2) <= std_logic_vector(ccnt_v);
	    clut_addr(3) <= std_logic_vector(ccnt_v);

	    clut_addr(4) <= std_logic_vector(rcnt_v);
	    clut_addr(5) <= std_logic_vector(rcnt_v);

	    lval_v := data_lval_d;
	    fval_v := data_fval_d;

	end if;
    end process;



    rc_noise_inst : entity work.row_col_noise
	port map (
	    clk => fifo_data_wclk,
	    clip => rcn_clip,
	    --
	    ch0_in => llut_dout_ch0_dd,
	    ch1_in => llut_dout_ch1_dd,
	    ch2_in => llut_dout_ch2_dd,
	    ch3_in => llut_dout_ch3_dd,
	    --
	    c0r0_lut => clut_dout_dd(0),
	    c1r0_lut => clut_dout_dd(1),
	    c0r1_lut => clut_dout_dd(2),
	    c1r1_lut => clut_dout_dd(3),
	    --
	    r0_lut => clut_dout_dd(4),
	    r1_lut => clut_dout_dd(5),
	    --
	    ch0_out => data_rcn_ch0,
	    ch1_out => data_rcn_ch1,
	    ch2_out => data_rcn_ch2,
	    ch3_out => data_rcn_ch3 );	

    copy_proc : process (fifo_data_wclk)
    begin
	if rising_edge(fifo_data_wclk) then
	/*  data_rcn_ch0 <= llut_dout_ch0(15 downto 0);
	    data_rcn_ch1 <= llut_dout_ch1(15 downto 0);
	    data_rcn_ch2 <= llut_dout_ch2(15 downto 0);
	    data_rcn_ch3 <= llut_dout_ch3(15 downto 0); */

	    llut_dout_ch0_dd <= llut_dout_ch0_d;
	    llut_dout_ch1_dd <= llut_dout_ch1_d;
	    llut_dout_ch2_dd <= llut_dout_ch2_d;
	    llut_dout_ch3_dd <= llut_dout_ch3_d; 

	    llut_dout_ch0_d <= llut_dout_ch0;
	    llut_dout_ch1_d <= llut_dout_ch1;
	    llut_dout_ch2_d <= llut_dout_ch2;
	    llut_dout_ch3_d <= llut_dout_ch3; 

	    match_en_d <= match_en;
	    match_en <= '1'
		when (data_ctrl_dd(2 downto 0) and reg_mask) = reg_mval
		else '0';

	    data_ctrl_ddd <= data_ctrl_dd;

	end if;

    	data_rcn(63 downto 52) <= data_rcn_ch0(15 downto 4);
	data_rcn(51 downto 40) <= data_rcn_ch1(15 downto 4);
	data_rcn(39 downto 28) <= data_rcn_ch2(15 downto 4);
	data_rcn(27 downto 16) <= data_rcn_ch3(15 downto 4);
    /*	data_rcn(63 downto 52) <= data_rcn_ch0(11 downto 0);
	data_rcn(51 downto 40) <= data_rcn_ch1(11 downto 0);
	data_rcn(39 downto 28) <= data_rcn_ch2(11 downto 0);
	data_rcn(27 downto 16) <= data_rcn_ch3(11 downto 0); */
	data_rcn(15 downto 0)  <= x"0" & data_ctrl_ddd;
    end process;


    -- data_in_c(63 downto 16) <= data_in(63 downto 16);

    cmv_active <= or_reduce(data_ctrl(2 downto 0) and reg_amsk);

    data_rcn_wen <= data_wen_dd(0) and match_en_d;

    -- fifo_data_wclk <= iserdes_clk;
    fifo_data_wen <= data_rcn_wen when fifo_data_wrdy = '1' else '0';
    wdata_full <= fifo_data_full when fifo_data_wrdy = '1' else '1';
    fifo_data_in <= data_rcn;

    fifo_data_rclk <= wdata_clk;
    fifo_data_ren <=
	wdata_enable and not fifo_data_empty when
	    fifo_data_rrdy = '1' else '0';
    wdata_empty <=
	fifo_data_low when
	    fifo_data_rrdy = '1' and sync_wempty = '0' else
	'0' when 
	    fifo_data_rrdy = '1' and sync_wempty = '1' else '1';
    wdata_in <= fifo_data_out;

    --------------------------------------------------------------------
    -- AXIHP Writer
    --------------------------------------------------------------------

    axihp_writer_inst : entity work.axihp_writer
	generic map (
	    DATA_WIDTH => 64,
	    DATA_COUNT => 16,
	    ADDR_MASK => WADDR_MASK(0),
	    ADDR_DATA => WADDR_BASE(0) )
	port map (
	    m_axi_aclk => writer_clk,		-- in
	    m_axi_areset_n => s_axi_areset_n(0), -- in
	    enable => writer_enable(0),		-- in
	    inactive => writer_inactive(0),	-- out
	    --
	    m_axi_wo => s_axi_wi(0),
	    m_axi_wi => s_axi_wo(0),
	    --
	    addr_clk => waddr_clk,		-- out
	    addr_enable => waddr_enable,	-- out
	    addr_in => waddr_in,		-- in
	    addr_empty => waddr_empty,		-- in
	    --
	    data_clk => wdata_clk,		-- out
	    data_enable => wdata_enable,	-- out
	    data_in => wdata_in,		-- in
	    data_empty => wdata_empty,		-- in
	    --
	    write_strobe => write_strobe,	-- in
	    --
	    writer_error => writer_error(0),	-- out
	    writer_active => writer_active,	-- out
	    writer_unconf => writer_unconf );	-- out

    s_axi_aclk(0) <= writer_clk;

    --------------------------------------------------------------------
    -- Capture Sequencer
    --------------------------------------------------------------------

    cseq_frmreq_proc : process (cseq_clk)
	variable done_v : std_logic := '0';
	variable shift_v : std_logic_vector (15 downto 0)
	    := (0 => '1', others => '0');
    begin
	if rising_edge(cseq_clk) then
	    if shift_v(0) = '1' then
		if cseq_req = '1' then
		    shift_v(shift_v'high) := '1';
		    shift_v(0) := '0';
		end if;

		cseq_wblock <= '0';
		cseq_wreset <= '0';
		cseq_wload <= '0';
		cseq_wswitch <= '0';

		cseq_wempty <= '0';
		cseq_frmreq <= '0';

	    else
		-- block address generator
		if shift_v(shift_v'high - 1) = '1' then
		    cseq_wblock <= '1';
		end if;

		-- flush out fifo/writer queue
		if shift_v(shift_v'high - 2) = '1' then
		    cseq_wempty <= '1';
		end if;


		-- load address
		cseq_wload <= shift_v(8);

		-- enable proper fifo
		if shift_v(7) = '1' then
		    cseq_wempty <= '0';
		end if;

		-- unblock address generator
		if shift_v(6) = '1' then
		    cseq_wblock <= '0';
		end if;

		-- capture done toggle
		if shift_v(5) = '1' then
		    done_v := cseq_done;
		end if;

		-- trigger framereq
		cseq_frmreq <= shift_v(4);

		-- switch buffers
		cseq_flip <= shift_v(2);

		if shift_v(0) = '0' then
		    -- wait for inactive writer
		    if shift_v(9) = '1' and sync_winact = '0' then
			null;

		    -- wait for capture complete
		    elsif shift_v(3) = '1' and cseq_done = done_v then
			null;

		    -- wait for rearm event
		    elsif shift_v(1) = '1' and sync_arm = '0' then
			null;

		    -- advance sequencer
		    else
			shift_v := '0' & shift_v(shift_v'high downto 1);

		    end if;
		end if;
	    end if;
	    cseq_shift(shift_v'range) <= shift_v;

	    -- pmod_jal(0) <= shift_v(2);
	    -- pmod_jal(1) <= shift_v(4);
	    -- pmod_jal(2) <= cseq_done;
	    -- pmod_jal(3) <= sync_arm;
	end if;
    end process;



    cseq_switch_proc : process (cseq_clk)
	variable rbuf_sel_v : unsigned (1 downto 0) := "00";
	variable wbuf_sel_v : unsigned (1 downto 0) := "00";

	function switch_f (
	    sel : unsigned (1 downto 0);
	    valid : std_logic_vector (3 downto 0) )
	    return unsigned is

	    variable sel_v : natural := to_integer(unsigned(sel));
	    variable sel_n_v : natural;
	begin
	    for I in 0 to 3 loop
		sel_n_v := (sel_v + I + 1) mod 4;
		if valid(sel_n_v) = '1' then
		    return to_unsigned(sel_n_v, 2);
		end if;
	    end loop;
	    return "00";
	end function;

    begin
	if rising_edge(cseq_clk) then
	    rbuf_sel <= std_logic_vector(rbuf_sel_v);
	    wbuf_sel <= std_logic_vector(wbuf_sel_v);

	    if cseq_flip = '1' then
		rbuf_sel_v := wbuf_sel_v;
		wbuf_sel_v := switch_f(wbuf_sel_v, wbuf_enable);
		cseq_switch <= '1';
	    else
		cseq_switch <= '0';
	    end if;
	end if;
    end process;


    sync_rbuf_sel_inst : entity work.sync_delay
	generic map (
	    STAGES => 1,
	    DATA_WIDTH => rbuf_sel'length )
	port map (
	    clk => raddr_clk,
	    data_in => rbuf_sel,
	    data_out => raddr_sel_in );

    sync_wbuf_sel_inst : entity work.sync_delay
	generic map (
	    STAGES => 1,
	    DATA_WIDTH => wbuf_sel'length )
	port map (
	    clk => waddr_clk,
	    data_in => wbuf_sel,
	    data_out => waddr_sel_in );



    cseq_prio_proc : process (cseq_shift)
    begin
	for I in 15 downto 0 loop
	    if cseq_shift(I) = '1' then
		-- pmod_jal(7 downto 4) <=
		--    std_logic_vector(to_unsigned(I, 4));
		-- pmod_jal(7) <= std_logic(to_unsigned(I, 4)(0));
		exit;
	    end if;
	end loop;
    end process;


--  div_cseq_inst : entity work.async_div
--	generic map (
--	    STAGES => 2 )
--	port map (
--	    clk_in => cmv_cmd_clk,
--	    clk_out => cseq_clk );

    cseq_clk <= cmv_cmd_clk;

    done_proc : process (cseq_clk)
	variable toggle_v : std_logic := '0';
    begin
	if rising_edge(cseq_clk) then
	    if sync_done = '1' then
		toggle_v := not toggle_v;
		cseq_fcnt <=
		    std_logic_vector(unsigned(cseq_fcnt) + "1");
	    end if;
	end if;

	cseq_done <= toggle_v;
    end process;

    sync_done_inst : entity work.pulse_sync
	generic map (
	    ACTIVE_IN => '0',
	    ACTIVE_OUT => '1' )
	port map (
	    clk => cseq_clk,
	    async_in => cmv_active,
	    sync_out => sync_done );

    sync_arm_inst : entity work.pulse_sync
	generic map (
	    ACTIVE_IN => '1',
	    ACTIVE_OUT => '1' )
	port map (
	    clk => cseq_clk,
	    async_in => scan_arm,
	    sync_out => sync_arm );

    --------------------------------------------------------------------
    -- Capture Event Synchronizers
    --------------------------------------------------------------------

    sync_wblock_inst : entity work.data_sync
	port map (
	    clk => waddr_clk,
	    async_in => cseq_wblock,
	    sync_out => sync_wblock );

    sync_wreset_inst : entity work.pulse_sync
	port map (
	    clk => waddr_clk,
	    async_in => cseq_wreset,
	    sync_out => sync_wreset );

    sync_wload_inst : entity work.pulse_sync
	port map (
	    clk => waddr_clk,
	    async_in => cseq_wload,
	    sync_out => sync_wload );

    sync_wswitch_inst0 : entity work.pulse_sync
	port map (
	    clk => waddr_clk,
	    async_in => cseq_switch,
	    sync_out => sync_wswitch(0) );

    sync_wswitch_inst1 : entity work.pulse_sync
	port map (
	    clk => waddr_clk,
	    async_in => oreg_wswitch,
	    sync_out => sync_wswitch(1) );

    waddr_block <= sync_wblock or oreg_wblock;
    waddr_reset <= sync_wreset or oreg_wreset;
    waddr_load <= sync_wload or oreg_wload;
    waddr_switch <= or_reduce(sync_wswitch);

    sync_wempty_inst : entity work.data_sync
	port map (
	    clk => wdata_clk,
	    async_in => cseq_wempty,
	    sync_out => sync_wempty );

    sync_winact_inst : entity work.data_sync
	port map (
	    clk => cseq_clk,
	    async_in => writer_inactive(0),
	    sync_out => sync_winact );

    sync_frmreq_inst0 : entity work.pulse_sync
	port map (
	    clk => cmv_cmd_clk,
	    async_in => cseq_frmreq,
	    sync_out => sync_frmreq );

    cmv_frame_req <= sync_frmreq;

    sync_frmreq_inst1 : entity work.pulse_sync
	port map (
	    clk => ilu_clk,
	    async_in => sync_frmreq,
	    sync_out => ilu_frmreq );

    --------------------------------------------------------------------
    -- LED/Button/Switch Override
    --------------------------------------------------------------------

    swi_ovr <= (swi and not swi_mask) or (swi_val and swi_mask);
    btn_ovr <= (btn and not btn_mask) or (btn_val and btn_mask);
    led <= (led_out and not led_mask) or (led_val and led_mask);

--  div_mask_64 <= reg_oreg(17) & reg_oreg(16);
--  div_mask <= div_mask_64(CHANNELS + 8 downto 0);
--  led_done <= xor_reduce((led_out & div_out) and div_mask);
    led_done <= cmv_active;

    --------------------------------------------------------------------
    -- Button input
    --------------------------------------------------------------------

    cseq_req <= btn_ovr(0);
    cmv_t_exp1 <= btn_ovr(1);
    cmv_t_exp2 <= btn_ovr(2);
    cmv_sys_res_n <= not btn_ovr(3);

    --------------------------------------------------------------------
    -- LED Status output
    --------------------------------------------------------------------

    led_out(0) <= cmv_pll_locked;
    led_out(1) <= lvds_pll_locked and idelay_valid;
    led_out(2) <= hdmi_pll_locked;

    led_out(3) <= cmv_active;
    led_out(4) <= wdata_full;

    div_hdmi_inst : entity work.async_div
	generic map (
	    STAGES => 28 )
	port map (
	    clk_in => hdmi_clk,
	    clk_out => led_out(5) );

    div_lvds_inst0 : entity work.async_div
	generic map (
	    STAGES => 28 )
	port map (
	    clk_in => cmv_lvds_clk,
	    clk_out => led_out(6) );

    div_lvds_inst1 : entity work.async_div
	generic map (
	    STAGES => 28 )
	port map (
	    clk_in => lvds_clk,
	    clk_out => led_out(7) );

    --------------------------------------------------------------------
    -- Exotic Stuff
    --------------------------------------------------------------------

    STARTUPE2_inst : STARTUPE2
	generic map (
	    PROG_USR => "FALSE",	-- Program event security feature.
	    SIM_CCLK_FREQ => 0.0 )	-- Configuration Clock Frequency(ns)
	port map (
	    CFGCLK => open,		-- 1-bit output: Configuration main clock output
	    CFGMCLK => open,		-- 1-bit output: Configuration internal oscillator clock output
	    EOS => open,		-- 1-bit output: Active high output signal indicating the End Of Startup.
	    PREQ => open,		-- 1-bit output: PROGRAM request to fabric output
	    CLK => '0',			-- 1-bit input: User start-up clock input
	    GSR => '0',			-- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
	    GTS => '0',			-- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
	    KEYCLEARB => '0',		-- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
	    PACK => '0',		-- 1-bit input: PROGRAM acknowledge input
	    USRCCLKO => '0',		-- 1-bit input: User CCLK input
	    USRCCLKTS => '0',		-- 1-bit input: User CCLK 3-state enable input
	    USRDONEO => '0',		-- 1-bit input: User DONE pin output control
	    USRDONETS => led_done );	-- 1-bit input: User DONE 3-state enable output

    USR_ACCESSE2_inst : USR_ACCESSE2
	port map (
	    CFGCLK => open,		-- 1-bit output: Configuration Clock output
	    DATA => usr_access,		-- 32-bit output: Configuration Data output
	    DATAVALID => open );	-- 1-bit output: Active high data valid output


    --------------------------------------------------------------------
    -- AXI3 HDMI Interconnect
    --------------------------------------------------------------------

    axi_lite_inst1 : entity work.axi_lite
	port map (
	    s_axi_aclk => m_axi1_aclk,
	    s_axi_areset_n => m_axi1_areset_n,

	    s_axi_ro => m_axi1_ri,
	    s_axi_ri => m_axi1_ro,
	    s_axi_wo => m_axi1_wi,
	    s_axi_wi => m_axi1_wo,

	    m_axi_ro => m_axi1l_ro,
	    m_axi_ri => m_axi1l_ri,
	    m_axi_wo => m_axi1l_wo,
	    m_axi_wi => m_axi1l_wi );

    m_axi1_aclk <= clk_100;

    axi_split_inst1 : entity work.axi_split8
	generic map (
	    SPLIT_BIT0 => 20,
	    SPLIT_BIT1 => 21,
	    SPLIT_BIT2 => 22 )
	port map (
	    s_axi_aclk => m_axi1_aclk,
	    s_axi_areset_n => m_axi1_areset_n,
	    --
	    s_axi_ro => m_axi1l_ri,
	    s_axi_ri => m_axi1l_ro,
	    s_axi_wo => m_axi1l_wi,
	    s_axi_wi => m_axi1l_wo,
	    --
	    m_axi_aclk => m_axi1a_aclk,
	    m_axi_areset_n => m_axi1a_areset_n,
	    --
	    m_axi_ri => m_axi1a_ri,
	    m_axi_ro => m_axi1a_ro,
	    m_axi_wi => m_axi1a_wi,
	    m_axi_wo => m_axi1a_wo );

    --------------------------------------------------------------------
    -- Scan Register File
    --------------------------------------------------------------------

    reg_file_inst1 : entity work.reg_file
	generic map (
	    REG_SPLIT => SCN_SPLIT,
	    OREG_SIZE => OSCN_SIZE,
	    IREG_SIZE => ISCN_SIZE )
	port map (
	    s_axi_aclk => m_axi1a_aclk(0),
	    s_axi_areset_n => m_axi1a_areset_n(0),
	    --
	    s_axi_ro => m_axi1a_ri(0),
	    s_axi_ri => m_axi1a_ro(0),
	    s_axi_wo => m_axi1a_wi(0),
	    s_axi_wi => m_axi1a_wo(0),
	    --
	    oreg => reg_oscn,
	    ireg => reg_iscn );

    reg_iscn(0) <= x"53434E" & x"0" &
		   std_logic_vector(to_unsigned(SCN_SPLIT, 4));
    reg_iscn(1) <= x"0" & scan_fcnt & x"00" & event_event;

    --------------------------------------------------------------------
    -- AddrGen Register File
    --------------------------------------------------------------------

    reg_file_inst2 : entity work.reg_file
	generic map (
	    REG_SPLIT => GEN_SPLIT,
	    OREG_SIZE => OGEN_SIZE,
	    IREG_SIZE => IGEN_SIZE )
	port map (
	    s_axi_aclk => m_axi1a_aclk(1),
	    s_axi_areset_n => m_axi1a_areset_n(1),
	    --
	    s_axi_ro => m_axi1a_ri(1),
	    s_axi_ri => m_axi1a_ro(1),
	    s_axi_wo => m_axi1a_wi(1),
	    s_axi_wi => m_axi1a_wo(1),
	    --
	    oreg => reg_ogen,
	    ireg => reg_igen );

    reg_igen(0) <= x"47454E" & x"0" &
		   std_logic_vector(to_unsigned(GEN_SPLIT, 4));
    reg_igen(1) <= raddr_in(31 downto 0);
    reg_igen(2) <= raddr_sel & "00" & reader_inactive &		-- 8bit
		   "00" & fifo_hdmi_wrerr & fifo_hdmi_rderr &	-- 4bit
		   fifo_hdmi_full & fifo_hdmi_high &		-- 2bit
		   fifo_hdmi_low & fifo_hdmi_empty &		-- 2bit
		   x"0000";					-- 16bit

    --------------------------------------------------------------------
    -- Color Matrix Register File
    --------------------------------------------------------------------

    reg_file_inst3 : entity work.reg_file
	generic map (
	    REG_SPLIT => MAT_SPLIT,
	    OREG_SIZE => OMAT_SIZE,
	    IREG_SIZE => IMAT_SIZE )
	port map (
	    s_axi_aclk => m_axi1a_aclk(2),
	    s_axi_areset_n => m_axi1a_areset_n(2),
	    --
	    s_axi_ro => m_axi1a_ri(2),
	    s_axi_ri => m_axi1a_ro(2),
	    s_axi_wo => m_axi1a_wi(2),
	    s_axi_wi => m_axi1a_wo(2),
	    --
	    oreg => reg_omat,
	    ireg => reg_imat );

    reg_imat(0) <= x"4D4154" & x"0" &
		   std_logic_vector(to_unsigned(MAT_SPLIT, 4));
    -- reg_imat(1) <= std_logic_vector(resize(signed(mat_v_out(0)), 32));
    -- reg_imat(2) <= std_logic_vector(resize(signed(mat_v_out(1)), 32));
    -- reg_imat(3) <= std_logic_vector(resize(signed(mat_v_out(2)), 32));


    --------------------------------------------------------------------
    -- BRAM LUT Register File
    --------------------------------------------------------------------

    reg_lut_inst1 : entity work.reg_lut_12x16
	generic map (
	    LUT_COUNT => DLUT_COUNT )
	port map (
	    s_axi_aclk => m_axi1a_aclk(3),
	    s_axi_areset_n => m_axi1a_areset_n(3),
	    --
	    s_axi_ro => m_axi1a_ri(3),
	    s_axi_ri => m_axi1a_ro(3),
	    s_axi_wo => m_axi1a_wi(3),
	    s_axi_wi => m_axi1a_wo(3),
	    --
	    lut_clk => data_clk,
	    lut_addr => dlut_addr,
	    lut_dout => dlut_dout );

    --------------------------------------------------------------------
    -- BRAM LUT Register File
    --------------------------------------------------------------------

    reg_mem_inst : entity work.reg_mem
	generic map (
	    DATA_WIDTH => 9,
	    ADDR_WIDTH => 12 )
	port map (
	    s_axi_aclk => m_axi1a_aclk(5),
	    s_axi_areset_n => m_axi1a_areset_n(5),
	    --
	    s_axi_ro => m_axi1a_ri(5),
	    s_axi_ri => m_axi1a_ro(5),
	    s_axi_wo => m_axi1a_wi(5),
	    s_axi_wi => m_axi1a_wo(5),
	    --
	    lut_clk => data_clk,
	    lut_addr => dmem_addr,
	    lut_dout => dmem_dout );

    --------------------------------------------------------------------
    -- HDMI Scan Generator
    --------------------------------------------------------------------

    hdmi_scan_inst : entity work.scan_hdmi
	port map (
	    clk => data_clk,
	    reset_n => '1',
	    --
	    total_w => reg_oscn(0)(11 downto 0),
	    total_h => reg_oscn(0)(27 downto 16),
	    total_f => reg_oscn(1)(11 downto 0),
	    --
	    hdisp_s => reg_oscn(2)(11 downto 0),
	    hdisp_e => reg_oscn(2)(27 downto 16),
	    vdisp_s => reg_oscn(3)(11 downto 0),
	    vdisp_e => reg_oscn(3)(27 downto 16),
	    --
	    hsync_s => reg_oscn(4)(11 downto 0),
	    hsync_e => reg_oscn(4)(27 downto 16),
	    vsync_s => reg_oscn(5)(11 downto 0),
	    vsync_e => reg_oscn(5)(27 downto 16),
	    --
	    hdata_s => reg_oscn(6)(11 downto 0),
	    hdata_e => reg_oscn(6)(27 downto 16),
	    vdata_s => reg_oscn(7)(11 downto 0),
	    vdata_e => reg_oscn(7)(27 downto 16),
	    --
	    event_0 => reg_oscn(8)(11 downto 0),
	    event_1 => reg_oscn(8)(27 downto 16),
	    event_2 => reg_oscn(9)(11 downto 0),
	    event_3 => reg_oscn(9)(27 downto 16),
	    --
	    event_4 => reg_oscn(10)(11 downto 0),
	    event_5 => reg_oscn(10)(27 downto 16),
	    event_6 => reg_oscn(11)(11 downto 0),
	    event_7 => reg_oscn(11)(27 downto 16),
	    --
	    pream_s => reg_oscn(16)(11 downto 0),
	    guard_s => reg_oscn(16)(27 downto 16),
	    terc4_e => reg_oscn(17)(11 downto 0),
	    guard_e => reg_oscn(17)(27 downto 16),
	    --
	    disp => scan_disp,
	    sync => scan_sync,
	    data => scan_data,
	    ctrl => scan_ctrl,
	    --
	    hevent => scan_hevent,
	    vevent => scan_vevent,
	    --
	    hcnt => scan_hcnt,
	    vcnt => scan_vcnt,
	    fcnt => scan_fcnt );

    scan_event_inst : entity work.scan_event
	port map (
	    clk => data_clk,
	    reset_n => '1',
	    --
	    disp_in => scan_disp,
	    sync_in => scan_sync,
	    data_in => scan_data,
	    ctrl_in => scan_ctrl,
	    --
	    hevent => scan_hevent,
	    vevent => scan_vevent,
	    --
	    hcnt_in => scan_hcnt,
	    vcnt_in => scan_vcnt,
	    fcnt_in => scan_fcnt,
	    --
	    data_eo => scan_eo,
	    econf => scan_econf,
	    --
	    hsync => hd_hsync,
	    vsync => hd_vsync,
	    pream => hd_pream,
	    guard => hd_guard,
	    disp => hd_de,
	    terc => hd_terc,
	    data => event_data,
	    --
	    event => event_event,
	    --
	    hcnt => event_hcnt,
	    vcnt => event_vcnt,
	    fcnt => event_fcnt );

    scan_eo <= reg_oscn(2)(0) xor reg_oscn(14)(0);
    scan_econf <= reg_oscn(13) & reg_oscn(12);

    event_cr <= x"FFF" when event_event(1) = '1' else x"000";
    event_cg <= x"FFF" when event_event(2) = '1' else x"000";
    event_cb <= x"FFF" when event_event(3) = '1' else x"000";

--  hd_edata <= event_cg & event_cr when event_event(0) = '1'
--	else x"4040" when event_data(0) = '0'
--	else hdmi_in(51 downto 44) & hdmi_in(63 downto 56);

--  hd_odata <= event_cg & event_cb when event_event(0) = '1'
--	else x"4040" when event_data(0) = '0'
--	else hdmi_in(39 downto 32) & hdmi_in(27 downto 20);


    matrix_inst : entity work.color_mat_4x4
	port map (
	    clk => data_clk,
	    clip => reg_oscn(14)(5 downto 4),
	    bypass => reg_oscn(14)(8),
	    --
	    matrix => mat_values,
	    adjust => mat_adjust,
	    offset => mat_offset,
	    --
	    v_in => mat_v_in,
	    v_out => mat_v_out );

    mat_v_in <= ( hdmi_ch0, hdmi_ch1, hdmi_ch2, hdmi_ch3 );

    mat_values <= (
	0 => ( reg_omat(0)(15 downto 0),
	       reg_omat(1)(15 downto 0),
	       reg_omat(2)(15 downto 0),
	       reg_omat(3)(15 downto 0) ),
	1 => ( reg_omat(4)(15 downto 0),
	       reg_omat(5)(15 downto 0),
	       reg_omat(6)(15 downto 0),
	       reg_omat(7)(15 downto 0) ),
	2 => ( reg_omat(8)(15 downto 0),
	       reg_omat(9)(15 downto 0),
	       reg_omat(10)(15 downto 0),
	       reg_omat(11)(15 downto 0) ),
	3 => ( reg_omat(12)(15 downto 0),
	       reg_omat(13)(15 downto 0),
	       reg_omat(14)(15 downto 0),
	       reg_omat(15)(15 downto 0) ));

    mat_adjust <= (
	0 => ( reg_omat(16)(15 downto 0),
	       reg_omat(17)(15 downto 0),
	       reg_omat(18)(15 downto 0),
	       reg_omat(19)(15 downto 0) ),
	1 => ( reg_omat(20)(15 downto 0),
	       reg_omat(21)(15 downto 0),
	       reg_omat(22)(15 downto 0),
	       reg_omat(23)(15 downto 0) ),
	2 => ( reg_omat(24)(15 downto 0),
	       reg_omat(25)(15 downto 0),
	       reg_omat(26)(15 downto 0),
	       reg_omat(27)(15 downto 0) ),
	3 => ( reg_omat(28)(15 downto 0),
	       reg_omat(29)(15 downto 0),
	       reg_omat(30)(15 downto 0),
	       reg_omat(31)(15 downto 0) ));

    mat_offset <= (
	reg_omat(32)(15 downto 0),
	reg_omat(33)(15 downto 0),
	reg_omat(34)(15 downto 0),
	reg_omat(35)(15 downto 0) );

    dlut_addr(0) <= mat_v_out(0);
    dlut_addr(1) <= mat_v_out(1);
    dlut_addr(2) <= mat_v_out(2);
    dlut_addr(3) <= mat_v_out(3);

    ch4_delay_inst : entity work.sync_delay
	generic map (
	    STAGES => 10,
	    DATA_WIDTH => 16 )
	port map (
	    clk => data_clk,
	    data_in => hdmi_ch4,
	    data_out => hdmi_ch4_d );

	
    overlay_proc : process (data_clk)
	variable a_v : unsigned(11 downto 0);
	variable b_v : unsigned(11 downto 0);
	variable c_v : unsigned(3 downto 0);
	variable o_v : unsigned(11 downto 0);

	type ci_t is array (natural range <>) of natural range 0 to 11;

	constant ci_c : ci_t(3 downto 0) := ( 8, 4, 0, 4 );
    begin
	if rising_edge(data_clk) then
	    dlut_dout_d <= dlut_dout;
	    for I in 3 downto 0 loop
		a_v := unsigned(dlut_dout_d(I)(15 downto 4));
		b_v := unsigned(hdmi_ch4_d(11 downto 0));
		c_v := unsigned(hdmi_ch4_d(ci_c(I)+3 downto ci_c(I)));
		
		case hdmi_ch4_d(15 downto 12) is
		    when "0001" =>
		    	o_v := b_v;

		    when "0010" =>
		    	o_v := c_v & c_v & c_v;

		    when "0011" =>
		    	o_v := not a_v;


		    when "0100" =>
		    	o_v := x"000" when scan_fcnt(4) else x"FFF";

		    when "0101" =>
		    	o_v := shift_right(a_v, 1) + shift_right(b_v, 1);

		    when "0110" =>
		    	o_v := shift_right(a_v, 1) + shift_right(c_v & c_v & c_v, 1);

		    when "0111" =>
		    	o_v := shift_right(not a_v, 1) + shift_right(b_v, 1);
		    

		    when "1000" =>
		    	o_v := x"000" when scan_fcnt(5) else x"FFF";

		    when "1001" =>
		    	o_v := b_v when scan_fcnt(5) else a_v;

		    when "1010" =>
		    	o_v := c_v & c_v & c_v when scan_fcnt(5) else a_v;

		    when "1011" =>
		    	o_v := not a_v when scan_fcnt(5) else a_v;


		    when "1100" =>
		    	o_v := x"000" when scan_fcnt(3) else x"FFF";

		    when "1101" =>
		    	o_v := x"000" when scan_fcnt(2) else x"FFF";

		    when "1110" =>
		    	o_v := x"000" when scan_fcnt(1) else x"FFF";

		    when "1111" =>
		    	o_v := x"000" when scan_fcnt(0) else x"FFF";
			
		    when others =>
			o_v := a_v;
		end case;

		hdmi_out(I*16+15 downto I*16) <=
		    std_logic_vector(o_v) & x"0";
	    end loop;	
	    -- conv_out <= conv_ch0 & conv_ch1 & conv_ch2 & conv_ch3;
	    -- hdmi_out <= conv_out;
	    -- hd_code <= hdmi_out;
	end if;
    end process;
    
    out_delay_inst : entity work.sync_delay
	generic map (
	    STAGES => 4,
	    DATA_WIDTH => 64 )
	port map (
	    clk => data_clk,
	    data_in => hdmi_out,
	    data_out => hd_code );

    -- hdmi_enable <= (event_data(0) and event_data(1))
    hdmi_enable <= event_data(0) or event_event(4);
    -- hdmi_enable <= (event_data(0) and event_data(1)) or event_event(4);


    --------------------------------------------------------------------
    -- TMDS Output
    --------------------------------------------------------------------

    OBUFDS_clk_inst0 : OBUFDS
	port map (
	    O => hdmi_south_clk_p,
	    OB => hdmi_south_clk_n,
	    I => tmds_south_io(3) );

    OBUFDS_GEN0: for I in 2 downto 0 generate
	OBUFDS_data_inst0 : OBUFDS
	    port map (
		O => hdmi_south_d_p(I),
		OB => hdmi_south_d_n(I),
		I => tmds_south_io(2 - I) );
    end generate;

/*  OBUFDS_clk_inst1 : OBUFDS
	port map (
	    O => hdmi_north_clk_p,
	    OB => hdmi_north_clk_n,
	    I => tmds_north_io(3) );

    OBUFDS_GEN1: for I in 2 downto 0 generate
	OBUFDS_data_inst1 : OBUFDS
	    port map (
		O => hdmi_north_d_p(I),
		OB => hdmi_north_d_n(I),
		I => tmds_north_io(2 - I) );
    end generate;	*/

    dil_proc : process (hdmi_clk)
	variable dil_addr_v : unsigned (11 downto 0)
	    := (others => '0');
    begin
	if rising_edge(hdmi_clk) then
	    if hd_vsync then
		if hd_terc then
		    dil_addr_v := dil_addr_v + '1';
		end if;
	    else
		dil_addr_v := (others => '0');
	    end if;
	    dmem_addr <= std_logic_vector(dil_addr_v);
	end if;
    end process;

    rgb_proc : process (hdmi_clk)

	variable cond : boolean;
	
	variable hd_r_d : std_logic_vector(11 downto 0);
	variable hd_b_d : std_logic_vector(11 downto 0);

	function "*" ( a : std_logic_vector; b : std_logic_vector )
	    return std_logic_vector is

	    variable res_v : std_logic_vector(a'high*2+1 downto a'low*2);
	    variable J : natural;
	begin
	    for I in a'high downto a'low loop
		J := I - a'low + b'low;
		res_v(I*2+1) := a(I);
		res_v(I*2) := b(J);
	    end loop;
	    return res_v;
	end function;

	function sel ( c : boolean; 
	    a : std_logic_vector;
	    b : std_logic_vector )
	    return std_logic_vector is
	begin
	    if c then
	    	return a;
	    else
	    	return b;
	    end if;
	end function;

    begin
	if rising_edge(hdmi_clk) then

	    cond := scan_fcnt(0) = '1' when reg_oscn(15)(25) = '1'
	    	else reg_oscn(15)(24) = '1';

	    case reg_oscn(15)(27 downto 26) is
		when "00" =>	-- normal output
		    rgb_data(0) <= hd_r(11 downto 4);
		    rgb_data(1) <= hd_g1(11 downto 4);
		    rgb_data(2) <= hd_b(11 downto 4);

		when "01" =>	-- r/g1, b/g2 alternate
		    rgb_data(0) <= sel(cond,
		    	 hd_r(11 downto 4), hd_b(11 downto 4));
		    rgb_data(1) <= sel(cond,
		    	 hd_g1(3 downto 0) * hd_r(3 downto 0), 
			 hd_g2(3 downto 0) * hd_b(3 downto 0));
		    rgb_data(2) <= sel(cond,
		    	 hd_g1(11 downto 4), hd_g2(11 downto 4));
			 
		when "10" =>	-- g1/g2, r/b fixed (AlexML)	
		    rgb_data(0) <= sel(cond,
		    	 hd_r(11 downto 4), hd_r_d(11 downto 4));
		    rgb_data(1) <= sel(cond,
		    	 hd_g1(11 downto 4), hd_g2(11 downto 4));
		    rgb_data(2) <= sel(cond,
		    	 hd_b(11 downto 4), hd_b_d(11 downto 4));

		when "11" =>	-- mix and match
		    rgb_data(0) <= sel(cond,
		    	hd_r(11 downto 4),
			hd_b(11 downto 8) & hd_r(3 downto 0));
		    rgb_data(1) <= sel(cond,
		    	hd_g1(11 downto 4),
			hd_g2(11 downto 8) * hd_g1(3 downto 0));
		    rgb_data(2) <= sel(cond,
		    	hd_b(11 downto 4),
			hd_r(11 downto 8) & hd_b(3 downto 0));

		-- when others =>
	    end case;

	    hd_r_d := hd_r;
	    hd_b_d := hd_b;

	    -- dil_data <= scan_hcnt(8 downto 0);
	    dil_data <= dmem_dout;
	    dil_de <= hd_terc;

	    rgb_de <= hd_de;

	    rgb_hsync <= hd_hsync;
	    rgb_vsync <= hd_vsync;
	    rgb_pream <= hd_pream;
	    rgb_guard <= hd_guard;

	end if;
    end process;

/*  rgb_dvid_inst : entity work.rgb_dvid
	port map (
	    pix_clk => hdmi_clk,
	    bit_clk => tmds_clk,
	    --
	    enable => tmds_enable,
	    reset => tmds_reset,
	    --
	    rgb => rgb_data,
	    --
	    de => rgb_de,
	    hsync => rgb_hsync,
	    vsync => rgb_vsync,
	    --
	    d0idx => reg_oscn(15)(1 downto 0),
	    d1idx => reg_oscn(15)(3 downto 2),
	    d2idx => reg_oscn(15)(5 downto 4),
	    clidx => reg_oscn(15)(7 downto 6),
	    --
	    d0inv => reg_oscn(15)(8),
	    d1inv => reg_oscn(15)(9),
	    d2inv => reg_oscn(15)(10),
	    clinv => reg_oscn(15)(11),
	    --
	    tmds => tmds_io );		*/


    tmds_reset_proc : process (hdmi_clk)
    begin
	if rising_edge(hdmi_clk) then
	    tmds_reset <= reg_oscn(15)(17);
	end if;
    end process;

    tmds_enable <= reg_oscn(15)(16);

    rgb_hdmi_inst0 : entity work.rgb_hdmi
	port map (
	    pix_clk => hdmi_clk,
	    bit_clk => tmds_clk,
	    --
	    enable => tmds_enable,
	    reset => tmds_reset,
	    --
	    rgb => rgb_data,
	    data => dil_data,
	    --
	    de => dil_de & rgb_de,
	    pream => rgb_pream,
	    guard => rgb_guard,
	    hsync => rgb_hsync,
	    vsync => rgb_vsync,
	    --
	    d0idx => reg_oscn(15)(1 downto 0),
	    d1idx => reg_oscn(15)(3 downto 2),
	    d2idx => reg_oscn(15)(5 downto 4),
	    clidx => reg_oscn(15)(7 downto 6),
	    --
	    d0inv => not reg_oscn(15)(8),
	    d1inv => reg_oscn(15)(9),
	    d2inv => reg_oscn(15)(10),
	    clinv => not reg_oscn(15)(11),
	    --
	    tmds => tmds_south_io );

    rgb_hdmi_inst1 : entity work.rgb_hdmi
	port map (
	    pix_clk => hdmi_clk,
	    bit_clk => tmds_clk,
	    --
	    enable => tmds_enable,
	    reset => tmds_reset,
	    --
	    rgb => rgb_data,
	    data => dil_data,
	    --
	    de => dil_de & rgb_de,
	    pream => rgb_pream,
	    guard => rgb_guard,
	    hsync => rgb_hsync,
	    vsync => rgb_vsync,
	    --
	    d0idx => reg_oscn(15)(1 downto 0),
	    d1idx => reg_oscn(15)(3 downto 2),
	    d2idx => reg_oscn(15)(5 downto 4),
	    clidx => reg_oscn(15)(7 downto 6),
	    --
	    d0inv => reg_oscn(15)(8),
	    d1inv => reg_oscn(15)(9),
	    d2inv => reg_oscn(15)(10),
	    clinv => reg_oscn(15)(11),
	    --
	    tmds => debug_tmds);
	    -- tmds => tmds_north_io );

    debug_data <= rgb_vsync & rgb_guard(2 downto 0);
    -- debug_data <= scan_hcnt(3 downto 0);

    debug_delay_inst : entity work.sync_delay
	generic map (
	    STAGES => 3,
	    DATA_WIDTH => debug'length )
	port map (
	    clk => hdmi_clk,
	    data_in => debug_data,
	    data_out => debug );



    --------------------------------------------------------------------
    -- Address Generator
    --------------------------------------------------------------------

    raddr_gen_inst : entity work.addr_qbuf
	port map (
	    clk => raddr_clk,
	    reset => raddr_reset,
	    load => raddr_load,
	    enable => raddr_enable,
	    --
	    sel_in => raddr_sel_in,
	    switch => raddr_switch,
	    --
	    buf0_addr => raddr_buf0,
	    buf1_addr => raddr_buf1,
	    buf2_addr => raddr_buf2,
	    buf3_addr => raddr_buf3,
	    --
	    col_inc => raddr_cinc,
	    col_cnt => raddr_ccnt,
	    --
	    row_inc => raddr_rinc,
	    --
	    buf0_epat => raddr_pat0,
	    buf1_epat => raddr_pat1,
	    buf2_epat => raddr_pat2,
	    buf3_epat => raddr_pat3,
	    --
	    addr => raddr_in,
	    match => raddr_match,
	    sel => raddr_sel );

    raddr_empty <= raddr_match or raddr_block;

    --------------------------------------------------------------------
    -- HDMI FIFO
    --------------------------------------------------------------------

    FIFO_hdmi_inst : FIFO_DUALCLOCK_MACRO
	generic map (
	    DEVICE => "7SERIES",
	    DATA_WIDTH => DATA_WIDTH,
	    ALMOST_FULL_OFFSET => x"020",
	    ALMOST_EMPTY_OFFSET => x"020",
	    FIFO_SIZE => "36Kb",
	    FIRST_WORD_FALL_THROUGH => TRUE )
	port map (
	    DI => fifo_hdmi_in,
	    WRCLK => fifo_hdmi_wclk,
	    WREN => fifo_hdmi_wen,
	    FULL => fifo_hdmi_full,
	    ALMOSTFULL => fifo_hdmi_high,
	    WRERR => fifo_hdmi_wrerr,
	    WRCOUNT => fifo_hdmi_wrcount,
	    --
	    DO => fifo_hdmi_out,
	    RDCLK => fifo_hdmi_rclk,
	    RDEN => fifo_hdmi_ren,
	    EMPTY => fifo_hdmi_empty,
	    ALMOSTEMPTY => fifo_hdmi_low,
	    RDERR => fifo_hdmi_rderr,
	    RDCOUNT => fifo_hdmi_rdcount,
	    --
	    RST => fifo_hdmi_rst );

    fifo_reset_inst1 : entity work.fifo_reset
	port map (
	    rclk => fifo_hdmi_rclk,
	    wclk => fifo_hdmi_wclk,
	    reset => fifo_hdmi_reset,
	    --
	    fifo_rst => fifo_hdmi_rst,
	    fifo_rrdy => fifo_hdmi_rrdy,
	    fifo_wrdy => fifo_hdmi_wrdy );

    fifo_hdmi_wclk <= rdata_clk;
    fifo_hdmi_wen <= rdata_enable when fifo_hdmi_wrdy = '1' else '0';
    rdata_full <= fifo_hdmi_high when fifo_hdmi_wrdy = '1' else '1';
    fifo_hdmi_in <= rdata_out;

    fifo_hdmi_rclk <= data_clk;
    fifo_hdmi_ren <= hdmi_enable when fifo_hdmi_rrdy = '1' else '0';
    rdata_empty <= fifo_hdmi_empty when fifo_hdmi_rrdy = '1' else '1';
    hdmi_in <= fifo_hdmi_out;

    --------------------------------------------------------------------
    -- AXIHP Reader
    --------------------------------------------------------------------

    axihp_reader_inst : entity work.axihp_reader
	generic map (
	    DATA_WIDTH => 64,
	    DATA_COUNT => 16,
	    ADDR_MASK => RADDR_MASK(2),
	    ADDR_DATA => RADDR_BASE(2) )
	port map (
	    m_axi_aclk => reader_clk,
	    m_axi_areset_n => s_axi_areset_n(2),
	    enable => reader_enable(2),
	    inactive => reader_inactive(2),	-- out
	    --
	    m_axi_ro => s_axi_ri(2),
	    m_axi_ri => s_axi_ro(2),
	    --
	    addr_clk => raddr_clk,		-- out
	    addr_enable => raddr_enable,	-- out
	    addr_in => raddr_in,		-- in
	    addr_empty => raddr_empty,		-- in
	    --
	    data_clk => rdata_clk,		-- out
	    data_enable => rdata_enable,	-- out
	    data_out => rdata_out,		-- out
	    data_full => rdata_full,		-- in
	    --
	    reader_error => reader_error(0),	-- out
	    reader_active => reader_active );	-- out

    s_axi_aclk(2) <= reader_clk;

    -- reader_enable <= enable;
    -- reader_data <= fifo_data_in;
    -- reader_addr <= fifo_addr_out;

    --------------------------------------------------------------------
    -- Scan Event Synchronizers
    --------------------------------------------------------------------

    sync_rblock_inst : entity work.data_sync
	port map (
	    clk => raddr_clk,
	    async_in => scan_rblock,
	    sync_out => sync_rblock );

    sync_rreset_inst : entity work.pulse_sync
	port map (
	    clk => raddr_clk,
	    async_in => scan_rreset,
	    sync_out => sync_rreset );

    sync_rload_inst : entity work.pulse_sync
	port map (
	    clk => raddr_clk,
	    async_in => scan_rload,
	    sync_out => sync_rload );

    sync_rswitch_inst0 : entity work.pulse_sync
	port map (
	    clk => raddr_clk,
	    async_in => cseq_switch,
	    sync_out => sync_rswitch(0) );

    sync_rswitch_inst1 : entity work.pulse_sync
	port map (
	    clk => raddr_clk,
	    async_in => ogen_rswitch,
	    sync_out => sync_rswitch(1) );

    raddr_block <= sync_rblock or ogen_rblock;
    raddr_reset <= sync_rreset or ogen_rreset;
    raddr_load <= sync_rload or ogen_rload;
    raddr_switch <= or_reduce(sync_rswitch);

    scan_rblock <= event_event(0);
    scan_rreset <= event_event(1);
    scan_rload <= event_event(2);
    scan_arm <= event_event(3);

end RTL;

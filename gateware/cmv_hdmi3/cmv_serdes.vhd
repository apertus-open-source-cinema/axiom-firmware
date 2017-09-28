----------------------------------------------------------------------------
--  cmv_serdes.vhd
--	LVDS Serial Deserializer
--	Version 1.2
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library unisim;
use unisim.vcomponents.ALL;

use work.vivado_pkg.ALL;


entity cmv_serdes is
    port (
	serdes_clk	: in  std_logic;
	serdes_clkdiv	: in  std_logic;
	serdes_phase	: in  std_logic;
	serdes_rst	: in  std_logic;
	--
	ser_data	: in  std_logic;
	par_data	: out std_logic_vector (11 downto 0);
	--
	bitslip		: in  std_logic
    );

end entity cmv_serdes;


architecture RTL of cmv_serdes is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal bitslip_occ : std_logic := '0';

    signal data : std_logic_vector (5 downto 0);
    signal data_out : std_logic_vector (11 downto 0);

begin

    ISERDES_master_inst : ISERDESE2
	generic map (
	    DATA_RATE		=> "SDR",
	    DATA_WIDTH		=> 6,
	    INTERFACE_TYPE	=> "NETWORKING",
	    IOBDELAY		=> "IFD",
	    OFB_USED		=> "FALSE",
	    SERDES_MODE		=> "MASTER",
	    IS_CLK_INVERTED	=> '0',
	    IS_CLKB_INVERTED	=> '1',
	    IS_CLKDIV_INVERTED	=> '0',
	    IS_CLKDIVP_INVERTED	=> '1',
	    NUM_CE		=> 1 )
	port map (
	    Q1		=> data(5),
	    Q2		=> data(4),
	    Q3		=> data(3),
	    Q4		=> data(2),
	    Q5		=> data(1),
	    Q6		=> data(0),
	    BITSLIP	=> bitslip_occ,
	    CE1		=> '1',
	    CE2		=> '1',
	    CLK		=> serdes_clk,
	    CLKB	=> serdes_clk,
	    CLKDIV	=> serdes_clkdiv,
	    CLKDIVP	=> serdes_clkdiv,
	    D		=> '0',
	    DDLY	=> ser_data,
	    DYNCLKDIVSEL => '0',
	    DYNCLKSEL	=> '0',
	    OCLK	=> '0',
	    OCLKB	=> '0',
	    OFB		=> '0',
	    RST		=> serdes_rst,
	    SHIFTIN1	=> '0',
	    SHIFTIN2	=> '0' );


    clkdiv_proc : process (serdes_clkdiv)
    begin
	if rising_edge(serdes_clkdiv) then
	    if serdes_phase = '1' then
		data_out(11 downto 6) <= data;
	    else
		data_out(5 downto 0) <= data;
	    end if;
	end if;
    end process;

    par_data <= data_out;

    bitslip_proc : process (serdes_clkdiv, bitslip)
	variable shift_v : std_logic_vector (1 downto 0) := "10";
    begin
	if bitslip = '1' then
	    shift_v := "10";
	else
	    if rising_edge(serdes_clkdiv) then
		shift_v := '0' & shift_v(1);
		bitslip_occ <= shift_v(0);
	    end if;
	end if;
    end process;

end RTL;

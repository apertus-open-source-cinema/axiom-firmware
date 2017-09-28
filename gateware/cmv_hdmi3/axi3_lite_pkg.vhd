----------------------------------------------------------------------------
--  axi3_lite_pkg.vhd
--	AXI3 Lite Specific Records, Types and Functions
--	Version 1.1
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

package axi3ml_pkg is

    type axi3ml_read_in_r is record
	--	read address
	arready : std_ulogic;
	--	read data
	rdata	: std_logic_vector (31 downto 0);
	rresp	: std_logic_vector (1 downto 0);
	rvalid	: std_ulogic;
    end record;

    type axi3ml_read_in_a is array (natural range <>) of
	axi3ml_read_in_r;

    type axi3ml_read_out_r is record
	--	read address
	araddr	: std_logic_vector (31 downto 0);
	arprot	: std_logic_vector (2 downto 0);
	arvalid : std_ulogic;
	--	read data
	rready	: std_ulogic;
    end record;

    type axi3ml_read_out_a is array (natural range <>) of
	axi3ml_read_out_r;

    type axi3ml_write_in_r is record
	--	write address
	awready : std_ulogic;
	--	write data
	wready	: std_ulogic;
	--	write response
	bresp	: std_logic_vector (1 downto 0);
	bvalid	: std_ulogic;
    end record;

    type axi3ml_write_in_a is array (natural range <>) of
	axi3ml_write_in_r;

    type axi3ml_write_out_r is record
	--	write address
	awaddr	: std_logic_vector (31 downto 0);
	awprot	: std_logic_vector (2 downto 0);
	awvalid : std_ulogic;
	--	write data
	wdata	: std_logic_vector (31 downto 0);
	wstrb	: std_logic_vector (3 downto 0);
	wvalid	: std_ulogic;
	--	write response
	bready	: std_ulogic;
    end record;

    type axi3ml_write_out_a is array (natural range <>) of
	axi3ml_write_out_r;

end;

package body axi3ml_pkg is

end package body;


library IEEE;
use IEEE.std_logic_1164.ALL;

package axi3sl_pkg is

    type axi3sl_read_in_r is record
	--	read address
	araddr	: std_logic_vector (31 downto 0);
	arprot	: std_logic_vector (2 downto 0);
	arvalid	: std_ulogic;
	--	read data
	rready	: std_ulogic;
    end record;

    type axi3sl_read_in_a is array (natural range <>) of
	axi3sl_read_in_r;

    type axi3sl_read_out_r is record
	--	read address
	arready	: std_ulogic;
	--	read data
	rdata	: std_logic_vector (63 downto 0);
	rresp	: std_logic_vector (1 downto 0);
	rvalid	: std_ulogic;
    end record;

    type axi3sl_read_out_a is array (natural range <>) of
	axi3sl_read_out_r;

    type axi3sl_write_in_r is record
	--	write address
	awaddr	: std_logic_vector (31 downto 0);
	awprot	: std_logic_vector (2 downto 0);
	awvalid	: std_ulogic;
	--	write data
	wdata	: std_logic_vector (63 downto 0);
	wstrb	: std_logic_vector (7 downto 0);
	wvalid	: std_ulogic;
	--	write response
	bready	: std_ulogic;
    end record;

    type axi3sl_write_in_a is array (natural range <>) of
	axi3sl_write_in_r;

    type axi3sl_write_out_r is record
	--	write address
	awready	: std_ulogic;
	--	write data
	wready	: std_ulogic;
	--	write response
	bresp	: std_logic_vector (1 downto 0);
	bvalid	: std_ulogic;
    end record;

    type axi3sl_write_out_a is array (natural range <>) of
	axi3sl_write_out_r;

end;

package body axi3sl_pkg is

end package body;

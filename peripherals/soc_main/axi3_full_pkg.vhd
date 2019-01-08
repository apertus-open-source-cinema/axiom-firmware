----------------------------------------------------------------------------
--  axi3_full_pkg.vhd
--	AXI3 Complete Records, Types and Functions
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

package axi3mf_pkg is

    type axi3mf_read_in_r is record
	--	read address
	arready : std_ulogic;
	--	read data
	rid	: std_logic_vector (11 downto 0);
	rdata	: std_logic_vector (31 downto 0);
	rlast	: std_ulogic;
	rresp	: std_logic_vector (1 downto 0);
	rvalid	: std_ulogic;
    end record;

    type axi3mf_read_in_a is array (natural range <>) of
	axi3mf_read_in_r;

    type axi3mf_read_out_r is record
	--	read address
	arid	: std_logic_vector (11 downto 0);
	araddr	: std_logic_vector (31 downto 0);
	arburst : std_logic_vector (1 downto 0);
	arlen	: std_logic_vector (3 downto 0);
	arsize	: std_logic_vector (1 downto 0);
	arlock	: std_logic_vector (1 downto 0);
	arprot	: std_logic_vector (2 downto 0);
	arcache	: std_logic_vector (3 downto 0);
	arqos	: std_logic_vector (3 downto 0);
	arvalid : std_ulogic;
	--	read data
	rready	: std_ulogic;
    end record;

    type axi3mf_read_out_a is array (natural range <>) of
	axi3mf_read_out_r;

    type axi3mf_write_in_r is record
	--	write address
	awready : std_ulogic;
	--	write data
	wready	: std_ulogic;
	--	write response
	bid	: std_logic_vector (11 downto 0);
	bresp	: std_logic_vector (1 downto 0);
	bvalid	: std_ulogic;
    end record;

    type axi3mf_write_in_a is array (natural range <>) of
	axi3mf_write_in_r;

    type axi3mf_write_out_r is record
	--	write address
	awid	: std_logic_vector (11 downto 0);
	awaddr	: std_logic_vector (31 downto 0);
	awburst : std_logic_vector (1 downto 0);
	awlen	: std_logic_vector (3 downto 0);
	awsize	: std_logic_vector (1 downto 0);
	awlock	: std_logic_vector (1 downto 0);
	awprot	: std_logic_vector (2 downto 0);
	awcache	: std_logic_vector (3 downto 0);
	awqos	: std_logic_vector (3 downto 0);
	awvalid : std_ulogic;
	--	write data
	wid	: std_logic_vector (11 downto 0);
	wdata	: std_logic_vector (31 downto 0);
	wstrb	: std_logic_vector (3 downto 0);
	wlast	: std_ulogic;
	wvalid	: std_ulogic;
	--	write response
	bready	: std_ulogic;
    end record;

    type axi3mf_write_out_a is array (natural range <>) of
	axi3mf_write_out_r;

end;

package body axi3mf_pkg is

end package body;


library IEEE;
use IEEE.std_logic_1164.ALL;

package axi3sf_pkg is

    type axi3sf_read_in_r is record
	--	read address
	arid	: std_logic_vector (5 downto 0);
	araddr	: std_logic_vector (31 downto 0);
	arburst	: std_logic_vector (1 downto 0);
	arlen	: std_logic_vector (3 downto 0);
	arsize	: std_logic_vector (1 downto 0);
	arlock	: std_logic_vector (1 downto 0);
	arprot	: std_logic_vector (2 downto 0);
	arcache	: std_logic_vector (3 downto 0);
	arqos	: std_logic_vector (3 downto 0);
	arvalid	: std_ulogic;
	--	read data
	rready	: std_ulogic;
    end record;

    type axi3sf_read_in_a is array (natural range <>) of
	axi3sf_read_in_r;

    type axi3sf_read_out_r is record
	--	read address
	arready	: std_ulogic;
	racount	: std_logic_vector (2 downto 0);
	--	read data
	rid	: std_logic_vector (5 downto 0);
	rdata	: std_logic_vector (63 downto 0);
	rlast	: std_ulogic;
	rresp	: std_logic_vector (1 downto 0);
	rvalid	: std_ulogic;
	rcount	: std_logic_vector (7 downto 0);
    end record;

    type axi3sf_read_out_a is array (natural range <>) of
	axi3sf_read_out_r;

    type axi3sf_write_in_r is record
	--	write address
	awid	: std_logic_vector (5 downto 0);
	awaddr	: std_logic_vector (31 downto 0);
	awburst	: std_logic_vector (1 downto 0);
	awlen	: std_logic_vector (3 downto 0);
	awsize	: std_logic_vector (1 downto 0);
	awlock	: std_logic_vector (1 downto 0);
	awprot	: std_logic_vector (2 downto 0);
	awcache	: std_logic_vector (3 downto 0);
	awqos	: std_logic_vector (3 downto 0);
	awvalid	: std_ulogic;
	--	write data
	wid	: std_logic_vector (5 downto 0);
	wdata	: std_logic_vector (63 downto 0);
	wstrb	: std_logic_vector (7 downto 0);
	wlast	: std_ulogic;
	wvalid	: std_ulogic;
	--	write response
	bready	: std_ulogic;
    end record;

    type axi3sf_write_in_a is array (natural range <>) of
	axi3sf_write_in_r;

    type axi3sf_write_out_r is record
	--	write address
	awready	: std_ulogic;
	wacount	: std_logic_vector (5 downto 0);
	--	write data
	wready	: std_ulogic;
	wcount	: std_logic_vector (7 downto 0);
	--	write response
	bid	: std_logic_vector (5 downto 0);
	bresp	: std_logic_vector (1 downto 0);
	bvalid	: std_ulogic;
    end record;

    type axi3sf_write_out_a is array (natural range <>) of
	axi3sf_write_out_r;

end;

package body axi3sf_pkg is

end package body;

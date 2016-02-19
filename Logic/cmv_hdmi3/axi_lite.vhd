----------------------------------------------------------------------------
--  axi_lite.vhd
--	ZedBoard simple VHDL example
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

use work.axi3m_pkg.ALL;		-- AXI3 Master
use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master


entity axi_lite is
    port (
	s_axi_aclk : in std_logic;
	s_axi_areset_n : in std_logic;
	--
	s_axi_ro : out axi3m_read_in_r;
	s_axi_ri : in axi3m_read_out_r;
	s_axi_wo : out axi3m_write_in_r;
	s_axi_wi : in axi3m_write_out_r;
	--
	m_axi_aclk : out std_logic;
	m_axi_areset_n : out std_logic;
	--
	m_axi_ri : in axi3ml_read_in_r;
	m_axi_ro : out axi3ml_read_out_r;
	m_axi_wi : in axi3ml_write_in_r;
	m_axi_wo : out axi3ml_write_out_r );

end entity axi_lite;


architecture RTL of axi_lite is

begin

    id_proc : process (s_axi_aclk)

	variable rwid : std_logic_vector (11 downto 0);

    begin
	if rising_edge(s_axi_aclk) then
	    if s_axi_areset_n = '0' then
		rwid := (others => '0');
	    else
		if s_axi_ri.arvalid = '1' then
		    rwid := s_axi_ri.arid;
		end if;
		if s_axi_wi.awvalid = '1' then
		    rwid := s_axi_wi.awid;
		end if;
	    end if;
	end if;

	s_axi_ro.rid <= rwid;
	s_axi_wo.bid <= rwid;
    end process;

    m_axi_aclk <= s_axi_aclk;
    m_axi_areset_n <= s_axi_areset_n;

    --	read address
    s_axi_ro.arready <= m_axi_ri.arready;
    --	read data
    s_axi_ro.rdata <= m_axi_ri.rdata;
    s_axi_ro.rlast <= '1';
    s_axi_ro.rresp <= m_axi_ri.rresp;
    s_axi_ro.rvalid <= m_axi_ri.rvalid;

    --	read address
    m_axi_ro.araddr <= s_axi_ri.araddr;
    m_axi_ro.arprot <= s_axi_ri.arprot;
    m_axi_ro.arvalid <= s_axi_ri.arvalid;
    --	read data
    m_axi_ro.rready <= s_axi_ri.rready;

    --	write address
    s_axi_wo.awready <= m_axi_wi.awready;
    --	write data
    s_axi_wo.wready <= m_axi_wi.wready;
    --	write response
    s_axi_wo.bresp <= m_axi_wi.bresp;
    s_axi_wo.bvalid <= m_axi_wi.bvalid;

    --	write address
    m_axi_wo.awaddr <= s_axi_wi.awaddr;
    m_axi_wo.awprot <= s_axi_wi.awprot;
    m_axi_wo.awvalid <= s_axi_wi.awvalid;
    --	write data
    m_axi_wo.wdata <= s_axi_wi.wdata;
    m_axi_wo.wstrb <= s_axi_wi.wstrb;
    m_axi_wo.wvalid <= s_axi_wi.wvalid;
    --	write response
    m_axi_wo.bready <= s_axi_wi.bready;


end RTL;

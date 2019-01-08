----------------------------------------------------------------------------
--  axihp_writer.vhd
--	AXIHP Writer (Async, In Flight)
--	Version 1.5
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
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

use work.axi3s_pkg.ALL;		-- AXI3 Slave Interface
use work.vivado_pkg.ALL;	-- Vivado Attributes


entity axihp_writer is
    generic (
	DATA_WIDTH : natural := 64;
	DATA_COUNT : natural := 16;
	ADDR_MASK : std_logic_vector (31 downto 0) := x"00FFFFFF";
	ADDR_DATA : std_logic_vector (31 downto 0) := x"1B000000" );
    port (
	m_axi_aclk	: in std_logic;
	m_axi_areset_n	: in std_logic;
	enable		: in std_logic;
	inactive	: out std_logic;
	--
	m_axi_wo	: out axi3s_write_in_r;
	m_axi_wi	: in axi3s_write_out_r;
	--
	addr_clk	: out std_logic;
	addr_enable	: out std_logic;
	addr_in		: in std_logic_vector (31 downto 0);
	addr_empty	: in std_logic;
	--
	data_clk	: out std_logic;
	data_enable	: out std_logic;
	data_in		: in std_logic_vector (DATA_WIDTH - 1 downto 0);
	data_empty	: in std_logic;
	--
	write_strobe	: in std_logic_vector (7 downto 0);
	--
	writer_error	: out std_logic;
	writer_active	: out std_logic_vector (3 downto 0);
	writer_unconf	: out std_logic_vector (3 downto 0) );

end entity axihp_writer;


architecture RTL of axihp_writer is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant awlen_c : std_logic_vector (3 downto 0)
	:= std_logic_vector (to_unsigned(DATA_COUNT - 1, 4));

    signal active : unsigned(3 downto 0) := x"0";
    signal unconf : unsigned(3 downto 0) := x"0";

    signal awvalid : std_logic := '0';
    signal wvalid : std_logic := '0';
    signal wlast : std_logic;
    signal bready : std_logic := '0';

    signal data_en : std_logic;
    signal addr_en : std_logic;
    signal resp_en : std_logic;

begin

    --------------------------------------------------------------------
    -- Address Pipeline
    --------------------------------------------------------------------

    addr_en <= awvalid and m_axi_wi.awready;

    addr_proc : process (m_axi_aclk, m_axi_wi)
    begin
	if rising_edge(m_axi_aclk) then
	    if m_axi_areset_n = '0' then	-- reset
		awvalid <= '0';

	    elsif awvalid = '0' then		-- idle phase
		if enable = '1' and		-- writer enabled
		    addr_empty = '0' and	-- address available
		    active(3) = '0' then	-- below max
		    awvalid <= '1';
		end if;
	    end if;

	    if awvalid = '1' then		-- active phase
		if m_axi_wi.awready = '1' then
		    awvalid <= '0';
		end if;
	    end if;
	end if;
    end process;

    m_axi_wo.awaddr <= (addr_in and ADDR_MASK) or ADDR_DATA;
    m_axi_wo.awvalid <= awvalid;

    addr_enable <= addr_en;


    --------------------------------------------------------------------
    -- Data Pipeline
    --------------------------------------------------------------------

    SRL16E_inst : SRL16E
	generic map (
	    INIT => x"0001")
	port map (
	    CLK => m_axi_aclk,			-- Clock input
	    CE => data_en,			-- Clock enable input
	    D => wlast,				-- SRL data input
	    Q => wlast,				-- SRL data output
	    A0 => awlen_c(0),			-- Select[0] input
	    A1 => awlen_c(1),			-- Select[1] input
	    A2 => awlen_c(2),			-- Select[2] input
	    A3 => awlen_c(3) );			-- Select[3] input

    data_en <= wvalid and m_axi_wi.wready;

    write_proc : process (m_axi_aclk, m_axi_wi)
    begin
	if rising_edge(m_axi_aclk) then
	    if m_axi_areset_n = '0' then	-- reset
		wvalid <= '0';

	    elsif wvalid = '0' then		-- idle phase
		if data_empty = '0' and		-- fifo not empty
		    active /= x"0" then		-- inactive
		    wvalid <= '1';
		end if;

	    else				-- active phase
		if wlast = '1' then
		    wvalid <= '0';
		end if;
	    end if;
	end if;
    end process;

    m_axi_wo.wdata(DATA_WIDTH - 1 downto 0) <= data_in;

    m_axi_wo.wvalid <= wvalid;
    m_axi_wo.wlast <= wlast;

    data_enable <= data_en;


    --------------------------------------------------------------------
    -- Response Pipeline
    --------------------------------------------------------------------

    resp_en <= bready and m_axi_wi.bvalid;

    bresp_proc : process (m_axi_aclk)
    begin
	if rising_edge(m_axi_aclk) then
	    if m_axi_areset_n = '0' then	-- reset
		bready <= '0';

	    elsif bready = '0' then		-- idle phase
		if enable = '1' then		-- writer enabled
		    bready <= '1';
		end if;

	    else				-- active phase
		if unconf = x"0" then		-- all done
		    bready <= '0';
		end if;
	    end if;
	end if;
    end process;

    m_axi_wo.bready <= bready;

    writer_error <= '1' when
	resp_en = '1' and m_axi_wi.bresp /= "00" else '0';


    --------------------------------------------------------------------
    -- In Flight Accounting
    --------------------------------------------------------------------

    active_proc : process (m_axi_aclk)
    begin
	if rising_edge(m_axi_aclk) then
	    if addr_en = '1' and
		wlast = '0' then		-- one more
		active <= active + "1";

	    elsif addr_en = '0' and
		wlast = '1' then		-- one less
		active <= active - "1";

	    end if;
	end if;
    end process;

    unconf_proc : process (m_axi_aclk)
    begin
	if rising_edge(m_axi_aclk) then
	    if addr_en = '1' and
		resp_en = '0' then		-- one more
		unconf <= unconf + "1";

	    elsif addr_en = '0' and
		resp_en = '1' then		-- one less
		unconf <= unconf - "1";

	    end if;
	end if;
    end process;

    inactive <= '1' when active = x"0"
	and unconf = x"0" else '0';


    --------------------------------------------------------------------
    -- Constant Values, Clocks
    --------------------------------------------------------------------

    m_axi_wo.awid <= (others => '0');
    m_axi_wo.wid <= (others => '0');

    m_axi_wo.awlen <= awlen_c;

    m_axi_wo.awburst <= "01";
    m_axi_wo.awsize <= "11";
    m_axi_wo.wstrb <= write_strobe;

    m_axi_wo.awprot <= "000";

    data_clk <= m_axi_aclk;
    addr_clk <= m_axi_aclk;

end RTL;

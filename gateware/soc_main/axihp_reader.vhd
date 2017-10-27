----------------------------------------------------------------------------
--  axihp_reader.vhd
--	AXIHP Reader (Async, In Flight)
--	Version 1.5
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

library unisim;
use unisim.VCOMPONENTS.ALL;

use work.axi3s_pkg.ALL;		-- AXI3 Slave Interface
use work.vivado_pkg.ALL;	-- Vivado Attributes


entity axihp_reader is
    generic (
	DATA_WIDTH : natural := 64;
	DATA_COUNT : natural := 16;
	ADDR_MASK : std_logic_vector(31 downto 0) := x"00FFFFFF";
	ADDR_DATA : std_logic_vector(31 downto 0) := x"1B000000" );
    port (
	m_axi_aclk	: in std_logic;
	m_axi_areset_n	: in std_logic;
	enable		: in std_logic;
	inactive	: out std_logic;
	--
	m_axi_ro	: out axi3s_read_in_r;
	m_axi_ri	: in axi3s_read_out_r;
	--
	data_clk	: out std_logic;
	data_enable	: out std_logic;
	data_out	: out std_logic_vector(DATA_WIDTH - 1 downto 0);
	data_full	: in std_logic;
	--
	addr_clk	: out std_logic;
	addr_enable	: out std_logic;
	addr_in		: in std_logic_vector(31 downto 0);
	addr_empty	: in std_logic;
	--
	reader_error	: out std_logic;
	reader_active	: out std_logic_vector (3 downto 0) );

end entity axihp_reader;

architecture RTL of axihp_reader is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant arlen_c : std_logic_vector (3 downto 0)
	:= std_logic_vector (to_unsigned(DATA_COUNT - 1, 4));

    signal active : unsigned(3 downto 0) := x"0";

    signal arvalid : std_logic := '0';
    signal rlast : std_logic;
    signal rready : std_logic := '0';

    signal data_en : std_logic;
    signal addr_en : std_logic;
    signal resp_en : std_logic;

begin

    --------------------------------------------------------------------
    -- Address Pipeline
    --------------------------------------------------------------------

    addr_en <= arvalid and m_axi_ri.arready;

    addr_proc : process (m_axi_aclk, m_axi_ri)
    begin
	if rising_edge(m_axi_aclk) then
	    if m_axi_areset_n = '0' then	-- reset
		arvalid <= '0';

	    elsif arvalid = '0' then		-- idle phase
		if enable = '1' and		-- writer enabled
		    addr_empty = '0' and	-- fifo not empty
		    active(3) = '0' then	-- below max
		    arvalid <= '1';
		end if;
	    end if;

	    if arvalid = '1' then		-- active phase
		if m_axi_ri.arready = '1' then
		    arvalid <= '0';
		end if;
	    end if;
	end if;
    end process;

    m_axi_ro.araddr <= (addr_in and ADDR_MASK) or ADDR_DATA;
    m_axi_ro.arvalid <= arvalid;

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
	    D => rlast,				-- SRL data input
	    Q => rlast,				-- SRL data output
	    A0 => arlen_c(0),			-- Select[0] input
	    A1 => arlen_c(1),			-- Select[1] input
	    A2 => arlen_c(2),			-- Select[2] input
	    A3 => arlen_c(3) );			-- Select[3] input

    data_en <= rready and m_axi_ri.rvalid;

    read_proc : process (m_axi_aclk, m_axi_ri)
    begin
	if rising_edge(m_axi_aclk) then
	    if m_axi_areset_n = '0' then	-- reset
		rready <= '0';

	    elsif rready = '0' then		-- idle phase
		if data_full = '0' and		-- fifo not full
		    active /= x"0" then		-- inactive
		    rready <= '1';
		end if;

	    else				-- active phase
		if m_axi_ri.rlast = '1' then
		    rready <= '0';
		end if;
	    end if;
	end if;
    end process;

    data_out <= m_axi_ri.rdata(DATA_WIDTH - 1 downto 0);

    m_axi_ro.rready <= rready;
    -- m_axi_ro.rlast <= rlast;

    data_enable <= data_en;

    reader_error <= '1' when
	data_en = '1' and m_axi_ri.rresp /= "00" else '0';

    --------------------------------------------------------------------
    -- In Flight Accounting
    --------------------------------------------------------------------

    active_proc : process (m_axi_aclk)
    begin
	if rising_edge(m_axi_aclk) then
	    if addr_en = '1' and
		m_axi_ri.rlast = '0' then	-- one more
		active <= active + "1";

	    elsif addr_en = '0' and
		m_axi_ri.rlast = '1' then	-- one less
		active <= active - "1";

	    end if;
	end if;
    end process;

    inactive <= '1' when active = x"0" else '0';


    --------------------------------------------------------------------
    -- Constant Values, Clocks
    --------------------------------------------------------------------

    m_axi_ro.arid <= (others => '0');

    m_axi_ro.arlen <= arlen_c;

    m_axi_ro.arburst <= "01";
    m_axi_ro.arsize <= "11";

    m_axi_ro.arprot <= "000";

    data_clk <= m_axi_aclk;
    addr_clk <= m_axi_aclk;

end RTL;

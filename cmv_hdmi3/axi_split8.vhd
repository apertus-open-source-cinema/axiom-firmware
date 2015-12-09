----------------------------------------------------------------------------
--  axi_split8.vhd
--	AXI3-Lite Address Splitter (triple bit)
--	Version 1.1
--
--  Copyright (C) 2014 H.Poetzl
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

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master


entity axi_split8 is
    generic (
	SPLIT_BIT0 : natural := 16;
	SPLIT_BIT1 : natural := 17;
	SPLIT_BIT2 : natural := 18
    );
    port (
	s_axi_aclk : in std_logic;
	s_axi_areset_n : in std_logic;
	--
	s_axi_ro : out axi3ml_read_in_r;
	s_axi_ri : in axi3ml_read_out_r;
	s_axi_wo : out axi3ml_write_in_r;
	s_axi_wi : in axi3ml_write_out_r;
	--
	m_axi_aclk : out std_logic_vector (7 downto 0);
	m_axi_areset_n : out std_logic_vector (7 downto 0);
	--
	m_axi_ri : in axi3ml_read_in_a(7 downto 0);
	m_axi_ro : out axi3ml_read_out_a(7 downto 0);
	m_axi_wi : in axi3ml_write_in_a(7 downto 0);
	m_axi_wo : out axi3ml_write_out_a(7 downto 0) );

end entity axi_split8;


architecture RTL of axi_split8 is

    constant bit_mask_c : std_logic_vector (31 downto 0) :=
	std_logic_vector (to_unsigned(2 ** SPLIT_BIT0, 32)) xor
	std_logic_vector (to_unsigned(2 ** SPLIT_BIT1, 32)) xor
	std_logic_vector (to_unsigned(2 ** SPLIT_BIT2, 32)) xor
	x"FFFFFFFF";

    signal r_sel : unsigned(2 downto 0) := "000";
    signal r_idle : boolean := true;

    signal w_sel : unsigned(2 downto 0) := "000";
    signal w_idle : boolean := true;

begin

    read_proc : process (s_axi_aclk)
	variable bits_v : unsigned(2 downto 0) := (others => '0');
    begin
	if rising_edge(s_axi_aclk) then
	    if r_idle then
		bits_v(0) := s_axi_ri.araddr(SPLIT_BIT0);
		bits_v(1) := s_axi_ri.araddr(SPLIT_BIT1);
		bits_v(2) := s_axi_ri.araddr(SPLIT_BIT2);

		if s_axi_ri.arvalid = '1' then
		    r_sel <= bits_v;
		    r_idle <= false;
		end if;

	    else
		if m_axi_ri(to_integer(bits_v)).rvalid = '1' then
		    r_idle <= true;
		end if;

	    end if;
	end if;

    end process;


    write_proc : process (s_axi_aclk)
	variable bits_v : unsigned(2 downto 0) := (others => '0');
    begin
	if rising_edge(s_axi_aclk) then
	    if w_idle then
		bits_v(0) := s_axi_wi.awaddr(SPLIT_BIT0);
		bits_v(1) := s_axi_wi.awaddr(SPLIT_BIT1);
		bits_v(2) := s_axi_wi.awaddr(SPLIT_BIT2);

		if s_axi_wi.awvalid = '1' then
		    w_sel <= bits_v;
		    w_idle <= false;
		end if;

	    else
		if m_axi_wi(to_integer(bits_v)).bvalid = '1' then
		    w_idle <= true;
		end if;

	    end if;
	end if;

    end process;


    s_axi_ro.arready  <= m_axi_ri(0).arready when r_sel = "000"
		    else m_axi_ri(1).arready when r_sel = "001"
		    else m_axi_ri(2).arready when r_sel = "010"
		    else m_axi_ri(3).arready when r_sel = "011"
		    else m_axi_ri(4).arready when r_sel = "100"
		    else m_axi_ri(5).arready when r_sel = "101"
		    else m_axi_ri(6).arready when r_sel = "110"
		    else m_axi_ri(7).arready when r_sel = "111";
    --
    s_axi_ro.rdata    <= m_axi_ri(0).rdata   when r_sel = "000"
		    else m_axi_ri(1).rdata   when r_sel = "001"
		    else m_axi_ri(2).rdata   when r_sel = "010"
		    else m_axi_ri(3).rdata   when r_sel = "011"
		    else m_axi_ri(4).rdata   when r_sel = "100"
		    else m_axi_ri(5).rdata   when r_sel = "101"
		    else m_axi_ri(6).rdata   when r_sel = "110"
		    else m_axi_ri(7).rdata   when r_sel = "111";

    s_axi_ro.rresp    <= m_axi_ri(0).rresp   when r_sel = "000"
		    else m_axi_ri(1).rresp   when r_sel = "001"
		    else m_axi_ri(2).rresp   when r_sel = "010"
		    else m_axi_ri(3).rresp   when r_sel = "011"
		    else m_axi_ri(4).rresp   when r_sel = "100"
		    else m_axi_ri(5).rresp   when r_sel = "101"
		    else m_axi_ri(6).rresp   when r_sel = "110"
		    else m_axi_ri(7).rresp   when r_sel = "111";

    s_axi_ro.rvalid   <= m_axi_ri(0).rvalid  when r_sel = "000"
		    else m_axi_ri(1).rvalid  when r_sel = "001"
		    else m_axi_ri(2).rvalid  when r_sel = "010"
		    else m_axi_ri(3).rvalid  when r_sel = "011"
		    else m_axi_ri(4).rvalid  when r_sel = "100"
		    else m_axi_ri(5).rvalid  when r_sel = "101"
		    else m_axi_ri(6).rvalid  when r_sel = "110"
		    else m_axi_ri(7).rvalid  when r_sel = "111";
    --
    s_axi_wo.awready  <= m_axi_wi(0).awready when w_sel = "000"
		    else m_axi_wi(1).awready when w_sel = "001"
		    else m_axi_wi(2).awready when w_sel = "010"
		    else m_axi_wi(3).awready when w_sel = "011"
		    else m_axi_wi(4).awready when w_sel = "100"
		    else m_axi_wi(5).awready when w_sel = "101"
		    else m_axi_wi(6).awready when w_sel = "110"
		    else m_axi_wi(7).awready when w_sel = "111";
    --
    s_axi_wo.wready   <= m_axi_wi(0).wready  when w_sel = "000"
		    else m_axi_wi(1).wready  when w_sel = "001"
		    else m_axi_wi(2).wready  when w_sel = "010"
		    else m_axi_wi(3).wready  when w_sel = "011"
		    else m_axi_wi(4).wready  when w_sel = "100"
		    else m_axi_wi(5).wready  when w_sel = "101"
		    else m_axi_wi(6).wready  when w_sel = "110"
		    else m_axi_wi(7).wready  when w_sel = "111";
    --
    s_axi_wo.bresp    <= m_axi_wi(0).bresp   when w_sel = "000"
		    else m_axi_wi(1).bresp   when w_sel = "001"
		    else m_axi_wi(2).bresp   when w_sel = "010"
		    else m_axi_wi(3).bresp   when w_sel = "011"
		    else m_axi_wi(4).bresp   when w_sel = "100"
		    else m_axi_wi(5).bresp   when w_sel = "101"
		    else m_axi_wi(6).bresp   when w_sel = "110"
		    else m_axi_wi(7).bresp   when w_sel = "111";

    s_axi_wo.bvalid   <= m_axi_wi(0).bvalid  when w_sel = "000"
		    else m_axi_wi(1).bvalid  when w_sel = "001"
		    else m_axi_wi(2).bvalid  when w_sel = "010"
		    else m_axi_wi(3).bvalid  when w_sel = "011"
		    else m_axi_wi(4).bvalid  when w_sel = "100"
		    else m_axi_wi(5).bvalid  when w_sel = "101"
		    else m_axi_wi(6).bvalid  when w_sel = "110"
		    else m_axi_wi(7).bvalid  when w_sel = "111";

    OUT_gen : for I in 7 downto 0 generate
	constant bit_v : unsigned (2 downto 0) := to_unsigned(I, 3);
    begin
	m_axi_aclk(I) <= s_axi_aclk;
	m_axi_areset_n(I) <= s_axi_areset_n;
	--
	m_axi_ro(I).araddr <= s_axi_ri.araddr and bit_mask_c;
	m_axi_ro(I).arprot <= (others => '0');
	m_axi_ro(I).arvalid <= s_axi_ri.arvalid
	    when not r_idle and r_sel = bit_v else '0';
	--
	m_axi_ro(I).rready  <= s_axi_ri.rready
	    when not r_idle and r_sel = bit_v else '0';
	--
	m_axi_wo(I).awaddr <= s_axi_wi.awaddr and bit_mask_c;
	m_axi_wo(I).wdata <= s_axi_wi.wdata;
	m_axi_wo(I).wstrb <= s_axi_wi.wstrb;
	m_axi_wo(I).awprot <= (others => '0');
	m_axi_wo(I).awvalid <= s_axi_wi.awvalid
	    when not w_idle and w_sel = bit_v else '0';
	m_axi_wo(I).wvalid  <= s_axi_wi.wvalid
	    when not w_idle and w_sel = bit_v else '0';
	--
	m_axi_wo(I).bready  <= s_axi_wi.bready
	    when not w_idle and w_sel = bit_v else '0';
    end generate;

end RTL;

----------------------------------------------------------------------------
--  axi_split4.vhd
--	AXI3-Lite Address Splitter (dual bit)
--	Version 1.1
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

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master


entity axi_split4 is
    generic (
	SPLIT_BIT0 : natural := 24;
	SPLIT_BIT1 : natural := 16
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
	m_axi_aclk : out std_logic_vector (3 downto 0);
	m_axi_areset_n : out std_logic_vector (3 downto 0);
	--
	m_axi_ri : in axi3ml_read_in_a(3 downto 0);
	m_axi_ro : out axi3ml_read_out_a(3 downto 0);
	m_axi_wi : in axi3ml_write_in_a(3 downto 0);
	m_axi_wo : out axi3ml_write_out_a(3 downto 0) );

end entity axi_split4;


architecture RTL of axi_split4 is

    constant bit_mask_c : std_logic_vector (31 downto 0) :=
	std_logic_vector (to_unsigned(2 ** SPLIT_BIT0, 32)) xor
	std_logic_vector (to_unsigned(2 ** SPLIT_BIT1, 32)) xor
	x"FFFFFFFF";

    signal r_sel : unsigned(1 downto 0) := "00";
    signal r_idle : boolean := true;

    signal w_sel : unsigned(1 downto 0) := "00";
    signal w_idle : boolean := true;

begin

    read_proc : process (s_axi_aclk)
	variable bits_v : unsigned(1 downto 0) := (others => '0');
    begin
	if rising_edge(s_axi_aclk) then
	    if r_idle then
		bits_v(0) := s_axi_ri.araddr(SPLIT_BIT0);
		bits_v(1) := s_axi_ri.araddr(SPLIT_BIT1);

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
	variable bits_v : unsigned(1 downto 0) := (others => '0');
    begin
	if rising_edge(s_axi_aclk) then
	    if w_idle then
		bits_v(0) := s_axi_wi.awaddr(SPLIT_BIT0);
		bits_v(1) := s_axi_wi.awaddr(SPLIT_BIT1);

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


    s_axi_ro.arready  <= m_axi_ri(0).arready when r_sel = "00"
		    else m_axi_ri(1).arready when r_sel = "01"
		    else m_axi_ri(2).arready when r_sel = "10"
		    else m_axi_ri(3).arready when r_sel = "11";
    --
    s_axi_ro.rdata    <= m_axi_ri(0).rdata   when r_sel = "00"
		    else m_axi_ri(1).rdata   when r_sel = "01"
		    else m_axi_ri(2).rdata   when r_sel = "10"
		    else m_axi_ri(3).rdata   when r_sel = "11";

    s_axi_ro.rresp    <= m_axi_ri(0).rresp   when r_sel = "00"
		    else m_axi_ri(1).rresp   when r_sel = "01"
		    else m_axi_ri(2).rresp   when r_sel = "10"
		    else m_axi_ri(3).rresp   when r_sel = "11";

    s_axi_ro.rvalid   <= m_axi_ri(0).rvalid  when r_sel = "00"
		    else m_axi_ri(1).rvalid  when r_sel = "01"
		    else m_axi_ri(2).rvalid  when r_sel = "10"
		    else m_axi_ri(3).rvalid  when r_sel = "11";
    --
    s_axi_wo.awready  <= m_axi_wi(0).awready when w_sel = "00"
		    else m_axi_wi(1).awready when w_sel = "01"
		    else m_axi_wi(2).awready when w_sel = "10"
		    else m_axi_wi(3).awready when w_sel = "11";
    --
    s_axi_wo.wready   <= m_axi_wi(0).wready  when w_sel = "00"
		    else m_axi_wi(1).wready  when w_sel = "01"
		    else m_axi_wi(2).wready  when w_sel = "10"
		    else m_axi_wi(3).wready  when w_sel = "11";
    --
    s_axi_wo.bresp    <= m_axi_wi(0).bresp   when w_sel = "00"
		    else m_axi_wi(1).bresp   when w_sel = "01"
		    else m_axi_wi(2).bresp   when w_sel = "10"
		    else m_axi_wi(3).bresp   when w_sel = "11";

    s_axi_wo.bvalid   <= m_axi_wi(0).bvalid  when w_sel = "00"
		    else m_axi_wi(1).bvalid  when w_sel = "01"
		    else m_axi_wi(2).bvalid  when w_sel = "10"
		    else m_axi_wi(3).bvalid  when w_sel = "11";

    OUT_gen : for I in 3 downto 0 generate
	constant bit_v : unsigned (1 downto 0) := to_unsigned(I, 2);
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

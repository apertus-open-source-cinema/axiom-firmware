----------------------------------------------------------------------------
--  axi_split.vhd
--	AXI3-Lite Address Splitter (single bit based)
--	Version 1.3
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


entity axi_split is
    generic (
	SPLIT_BIT : natural := 16
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
	m_axi_aclk : out std_logic_vector (1 downto 0);
	m_axi_areset_n : out std_logic_vector (1 downto 0);
	--
	m_axi_ri : in axi3ml_read_in_a(1 downto 0);
	m_axi_ro : out axi3ml_read_out_a(1 downto 0);
	m_axi_wi : in axi3ml_write_in_a(1 downto 0);
	m_axi_wo : out axi3ml_write_out_a(1 downto 0) );

end entity axi_split;


architecture RTL of axi_split is

    constant bit_mask_c : std_logic_vector (31 downto 0) :=
	std_logic_vector (to_unsigned(2 ** SPLIT_BIT, 32))
	xor x"FFFFFFFF";

    type boolean_a is array (natural range <>) of boolean;

    signal rsel : boolean_a(1 downto 0)
	:= (others => false);

    signal wsel : boolean_a(1 downto 0)
	:= (others => false);

begin

    split_proc : process (s_axi_aclk)

	type arb_state is ( idle_s, sel0_s, sel1_s );

	variable rstate : arb_state := idle_s;
	variable wstate : arb_state := idle_s;

	variable rsel_v : boolean_a(1 downto 0)
	    := (others => false);

	variable wsel_v : boolean_a(1 downto 0)
	    := (others => false);

    begin


	if rising_edge(s_axi_aclk) then
	    case rstate is
		when idle_s =>
		    rsel_v := (others => false);

		    if s_axi_ri.arvalid = '1' then
			if s_axi_ri.araddr(SPLIT_BIT) = '0' then
			    rstate := sel0_s;
			else
			    rstate := sel1_s;
			end if;
		    end if;

		when sel0_s =>
		    rsel_v(0) := true;

		    if m_axi_ri(0).rvalid = '1' then
			rstate := idle_s;
		    end if;

		when sel1_s =>
		    rsel_v(1) := true;

		    if m_axi_ri(1).rvalid = '1' then
			rstate := idle_s;
		    end if;

	    end case;

	    case wstate is
		when idle_s =>
		    wsel_v := (others => false);

		    if s_axi_wi.awvalid = '1' then
			if s_axi_wi.awaddr(SPLIT_BIT) = '0' then
			    wstate := sel0_s;
			else
			    wstate := sel1_s;
			end if;
		    end if;

		when sel0_s =>
		    wsel_v(0) := true;

		    if m_axi_wi(0).bvalid = '1' then
			wstate := idle_s;
		    end if;

		when sel1_s =>
		    wsel_v(1) := true;

		    if m_axi_wi(1).bvalid = '1' then
			wstate := idle_s;
		    end if;

	    end case;
	end if;

	rsel <= rsel_v;

	wsel <= wsel_v;

    end process;

    s_axi_ro.arready  <= m_axi_ri(0).arready when rsel(0) 
		    else m_axi_ri(1).arready when rsel(1) else '0';
    --
    s_axi_ro.rdata    <= m_axi_ri(0).rdata   when rsel(0)
		    else m_axi_ri(1).rdata   when rsel(1)
		    else (others => '0');
    s_axi_ro.rresp    <= m_axi_ri(0).rresp   when rsel(0)
		    else m_axi_ri(1).rresp   when rsel(1)
		    else (others => '0');
    s_axi_ro.rvalid   <= m_axi_ri(0).rvalid  when rsel(0)
		    else m_axi_ri(1).rvalid  when rsel(1) else '0';
    --
    s_axi_wo.awready  <= m_axi_wi(0).awready when wsel(0)
		    else m_axi_wi(1).awready when wsel(1) else '0';
    --
    s_axi_wo.wready   <= m_axi_wi(0).wready  when wsel(0)
		    else m_axi_wi(1).wready  when wsel(1) else '0';
    --
    s_axi_wo.bresp    <= m_axi_wi(0).bresp   when wsel(0)
		    else m_axi_wi(1).bresp   when wsel(1)
		    else (others => '0');
    s_axi_wo.bvalid   <= m_axi_wi(0).bvalid  when wsel(0)
		    else m_axi_wi(1).bvalid  when wsel(1) else '0';

    OUT_gen : for I in 1 downto 0 generate
    begin
	m_axi_aclk(I) <= s_axi_aclk;
	m_axi_areset_n(I) <= s_axi_areset_n;
	--
	m_axi_ro(I).araddr <= s_axi_ri.araddr and bit_mask_c;
	m_axi_ro(I).arprot <= (others => '0');
	m_axi_ro(I).arvalid <= s_axi_ri.arvalid	 when rsel(I) else '0';
	--
	m_axi_ro(I).rready  <= s_axi_ri.rready	 when rsel(I) else '0';
	--
	m_axi_wo(I).awaddr <= s_axi_wi.awaddr and bit_mask_c;
	m_axi_wo(I).wdata <= s_axi_wi.wdata;
	m_axi_wo(I).wstrb <= s_axi_wi.wstrb;
	m_axi_wo(I).awprot <= (others => '0');
	m_axi_wo(I).awvalid <= s_axi_wi.awvalid	 when wsel(I) else '0';
	m_axi_wo(I).wvalid  <= s_axi_wi.wvalid	 when wsel(I) else '0';
	--
	m_axi_wo(I).bready  <= s_axi_wi.bready	 when wsel(I) else '0';
    end generate;

end RTL;

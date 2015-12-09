----------------------------------------------------------------------------
--  reg_delay.vhd
--	AXI3 Lite IDELAY/SERDES Interface
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

library unisim;
use unisim.VCOMPONENTS.ALL;

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.vivado_pkg.ALL;	-- Vivado Attributes


entity reg_delay is
    generic (
	REG_BASE : natural := 16#60000000#;
	CHANNELS : natural := 32
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
	delay_clk : in std_logic;
	--
	delay_in : in std_logic_vector (CHANNELS - 1 downto 0);
	delay_out : out std_logic_vector (CHANNELS - 1 downto 0);
	--
	match : in std_logic_vector (CHANNELS - 1 downto 0);
	mismatch : in std_logic_vector (CHANNELS - 1 downto 0);
	--
	bitslip : out std_logic_vector (CHANNELS - 1 downto 0)
    );
end entity reg_delay;


architecture RTL of reg_delay is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant INDEX_WIDTH : natural := 6;

	-- s_axi_aclk domain
    signal axi_dly_go : std_logic := '0';
    signal axi_dly_done : std_logic;
    signal axi_dly_active : std_logic;

    signal reg_ab_in : std_logic_vector (INDEX_WIDTH + 6 downto 0);
    signal reg_ba_out : std_logic_vector (6 downto 0);

    alias axi_dly_index : std_logic_vector (INDEX_WIDTH - 1 downto 0)
	is reg_ab_in(INDEX_WIDTH + 6 downto 7);

    alias axi_pat_bitslip : std_logic is reg_ab_in(6);
    alias axi_dly_ld : std_logic is reg_ab_in(5);
    alias axi_dly_val : std_logic_vector (4 downto 0)
	is reg_ab_in(4 downto 0);

    alias axi_pat_match : std_logic is reg_ba_out(6);
    alias axi_pat_mismatch : std_logic is reg_ba_out(5);
    alias axi_dly_oval : std_logic_vector (4 downto 0)
	is reg_ba_out(4 downto 0);

	-- delay_clk domain
    signal dly_go : std_logic;
    signal dly_done : std_logic := '0';
    signal dly_action : std_logic;

    signal delay_ld : std_logic_vector (CHANNELS - 1 downto 0);

    type delay_val_a is array (natural range <>) of
	std_logic_vector (4 downto 0);

    signal delay_oval : delay_val_a (CHANNELS - 1 downto 0);

    signal delay_val : std_logic_vector (4 downto 0);

    signal reg_ba_in : std_logic_vector (6 downto 0);
    signal reg_ab_out : std_logic_vector (INDEX_WIDTH + 6 downto 0);

    alias dly_index : std_logic_vector (INDEX_WIDTH - 1 downto 0)
	is reg_ab_out(INDEX_WIDTH + 6 downto 7);

    alias pat_bitslip : std_logic is reg_ab_out(6);
    alias dly_ld : std_logic is reg_ab_out(5);
    alias dly_val : std_logic_vector (4 downto 0)
	is reg_ab_out(4 downto 0);

    alias pat_match : std_logic is reg_ba_in(6);
    alias pat_mismatch : std_logic is reg_ba_in(5);
    alias dly_oval : std_logic_vector (4 downto 0)
	is reg_ba_in(4 downto 0);

begin

    pp_reg_sync_inst : entity work.pp_reg_sync
	generic map (
	    AB_WIDTH => INDEX_WIDTH + 7,
	    BA_WIDTH => 7 )
	port map (
	    clk_a => s_axi_aclk,
	    ping_a => axi_dly_go,		-- in,  toggle
	    pong_a => axi_dly_done,		-- out, toggle
	    active => axi_dly_active,		-- out
	    --
	    reg_ab_in => reg_ab_in,
	    reg_ba_out => reg_ba_out,
	    --
	    clk_b => delay_clk,
	    ping_b => dly_go,			-- out, toggle
	    pong_b => dly_done,			-- in,  toggle
	    action => dly_action,		-- out
	    --
	    reg_ba_in => reg_ba_in,
	    reg_ab_out => reg_ab_out );


    GEN_DELAY: for I in CHANNELS - 1 downto 0 generate
	IDELAY_inst : IDELAYE2
	    generic map (
		HIGH_PERFORMANCE_MODE => "TRUE",
		IDELAY_TYPE	      => "VAR_LOAD",
		IDELAY_VALUE	      => 0,
		REFCLK_FREQUENCY      => 200.0,
		SIGNAL_PATTERN        => "DATA" )
	    port map (
		IDATAIN     => delay_in(I),
		DATAIN      => '0',
		DATAOUT     => delay_out(I),
		CINVCTRL    => '0',
		CNTVALUEIN  => delay_val,
		CNTVALUEOUT => delay_oval(I),
		LD	    => delay_ld(I),
		LDPIPEEN    => '0',
		C	    => delay_clk,
		CE	    => '0',
		INC	    => '0',
		REGRST      => '0' );

    end generate;


    --------------------------------------------------------------------
    -- Load Action and Reply
    --------------------------------------------------------------------

    action_proc : process (delay_clk, dly_action)
	variable index_v : natural;
    begin
	if rising_edge(delay_clk) then
	    index_v := to_integer(unsigned(dly_index));

	    if dly_action = '1' then
		delay_val <= dly_val;
		delay_ld(index_v) <= dly_ld;
		bitslip(index_v) <= pat_bitslip;

		dly_oval <= delay_oval(index_v);
		pat_match <= match(index_v);
		pat_mismatch <= mismatch(index_v);

		dly_done <= dly_go;	-- turn around
	    else
		delay_ld(index_v) <= '0';
		bitslip(index_v) <= '0';
	    end if;
	end if;
    end process;


    --------------------------------------------------------------------
    -- AXI Read/Write
    --------------------------------------------------------------------

    reg_rwseq_proc : process (
	s_axi_aclk, s_axi_areset_n,
	s_axi_ri, s_axi_wi, axi_dly_oval )

	variable addr_v : std_logic_vector (31 downto 0);
	variable index_v : integer := 0;

	variable arready_v : std_logic := '0';
	variable rvalid_v : std_logic := '0';

	variable awready_v : std_logic := '0';
	variable wready_v : std_logic := '0';
	variable bvalid_v : std_logic := '0';

	variable rresp_v : std_logic_vector (1 downto 0) := "00";

	variable wdata_v : std_logic_vector (31 downto 0);
	variable wstrb_v : std_logic_vector (3 downto 0);
	variable bresp_v : std_logic_vector (1 downto 0) := "00";

	type rw_state is (
	    idle_s,
	    r_addr_s, r_dly_s, r_data_s,
	    w_addr_s, w_data_s, w_dly_s, w_resp_s );

	variable state : rw_state := idle_s;

	function index_func ( val : integer )
	    return std_logic_vector is
	begin
	    return std_logic_vector (to_unsigned(val, INDEX_WIDTH));
	end function;

    begin
	if rising_edge(s_axi_aclk) then
	    if s_axi_areset_n = '0' then
		addr_v := (others => '0');

		arready_v := '0';
		rvalid_v := '0';

		awready_v := '0';
		wready_v := '0';
		bvalid_v := '0';

		state := idle_s;

	    else
		case state is
		    when idle_s =>
			rvalid_v := '0';
			bvalid_v := '0';

			if s_axi_ri.arvalid = '1' then	-- address _is_ valid
			    state := r_addr_s;

			elsif s_axi_wi.awvalid = '1' then -- address _is_ valid
			    state := w_addr_s;

			end if;

		--  ARVALID ---> RVALID		    Master
		--     \	 /`   \
		--	\,	/      \,
		--	 ARREADY     RREADY	    Slave

		    when r_addr_s =>
			addr_v := s_axi_ri.araddr;
			index_v :=
			    to_integer(unsigned(addr_v) - REG_BASE) / 4;

			if index_v >= 0 and
			    index_v < CHANNELS then
			    axi_dly_index <= index_func(index_v);
			    rresp_v := "00";		-- okay
			else
			    rresp_v := "11";		-- decode error
			end if;

			axi_dly_ld <= '0';
			axi_pat_bitslip <= '0';
			axi_dly_go <= not axi_dly_go;	-- toggle trigger

			arready_v := '1';		-- ready for transfer
			state := r_dly_s;

		    when r_dly_s =>			-- wait for delay
			arready_v := '0';		-- done with addr

			if axi_dly_active = '0' then
			    state := r_data_s;
			end if;

		    when r_data_s =>
			if s_axi_ri.rready = '1' then	-- master ready
			    rvalid_v := '1';		-- data is valid

			    state := idle_s;
			end if;

		--  AWVALID ---> WVALID	 _	       BREADY	    Master
		--     \    --__ /`   \	  --__		/`
		--	\,	/--__  \,     --_      /
		--	 AWREADY     -> WREADY ---> BVALID	    Slave

		    when w_addr_s =>
			addr_v := s_axi_wi.awaddr;
			index_v :=
			    to_integer(unsigned(addr_v) - REG_BASE) / 4;

			if index_v >= 0 and
			    index_v < CHANNELS then
			    axi_dly_index <= index_func(index_v);
			    bresp_v := "00";		-- okay
			else
			    bresp_v := "11";		-- decode error
			end if;

			awready_v := '1';		-- ready for transfer
			state := w_data_s;

		    when w_data_s =>
			awready_v := '0';		-- done with addr
			wready_v := '1';		-- ready for data

			if s_axi_wi.wvalid = '1' then	-- data transfer
			    wdata_v := s_axi_wi.wdata;
			    wstrb_v := s_axi_wi.wstrb;

			    axi_dly_ld <= not wdata_v(31);
			    axi_pat_bitslip <= wdata_v(31);
			    axi_dly_go <= not axi_dly_go;

			    state := w_dly_s;
			end if;

		    when w_dly_s =>			-- wait for delay
			wready_v := '0';		-- done with write

			if axi_dly_active = '0' then
			    state := w_resp_s;
			end if;

		    when w_resp_s =>
			if s_axi_wi.bready = '1' then	-- master ready
			    bvalid_v := '1';		-- response valid

			    state := idle_s;
			end if;

		end case;
	    end if;
	end if;

	s_axi_ro.arready <= arready_v;
	s_axi_ro.rvalid <= rvalid_v;

	s_axi_wo.awready <= awready_v;
	s_axi_wo.wready <= wready_v;
	s_axi_wo.bvalid <= bvalid_v;

	s_axi_ro.rresp <= rresp_v;

	s_axi_wo.bresp <= bresp_v;

	axi_dly_val <= wdata_v(4 downto 0);

	s_axi_ro.rdata(29) <= axi_pat_match;
	s_axi_ro.rdata(28) <= axi_pat_mismatch;
	s_axi_ro.rdata(4 downto 0) <= axi_dly_oval;

    end process;

end RTL;

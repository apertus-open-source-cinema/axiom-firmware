----------------------------------------------------------------------------
--  reg_mem.vhd
--	AXI3 Lite BRAM MEM Interface
--	Version 1.1
--
--  Copyright (C) 2015 H.Poetzl
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
use work.helper_pkg.ALL;	-- Helpers


entity reg_mem is
    generic (
	DATA_WIDTH : natural := 9;
	ADDR_WIDTH : natural := 12
    );
    port (
	s_axi_aclk : in std_logic;
	s_axi_areset_n : in std_logic;
	--	write address
	s_axi_ro : out axi3ml_read_in_r;
	s_axi_ri : in axi3ml_read_out_r;
	s_axi_wo : out axi3ml_write_in_r;
	s_axi_wi : in axi3ml_write_out_r;
	--
	lut_clk : in std_logic;
	lut_addr : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	lut_dout : out std_logic_vector (DATA_WIDTH - 1 downto 0)
    );
end entity reg_mem;


architecture RTL of reg_mem is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal mem_addr : std_logic_vector (ADDR_WIDTH - 1 downto 0);

    signal mem_din : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal mem_dout : std_logic_vector (DATA_WIDTH - 1 downto 0);

    signal mem_we : std_logic := '0';
    signal mem_re : std_logic := '0';

    alias araddr: std_logic_vector (ADDR_WIDTH - 1 downto 0)
	is s_axi_ri.araddr(ADDR_WIDTH + 1 downto 2);
    alias awaddr: std_logic_vector (ADDR_WIDTH - 1 downto 0)
	is s_axi_wi.awaddr(ADDR_WIDTH + 1 downto 2);

    function addr_f ( val : std_logic_vector )
	return std_logic_vector is
    begin
	return val(ADDR_WIDTH - 1 downto 0);
    end function;

begin

    bram_lut_inst : entity work.bram_lut
    	generic map (
    	    DATA_WIDTH => DATA_WIDTH,
    	    ADDR_WIDTH => ADDR_WIDTH )
    	port map (
    	    lut_clk => lut_clk,
    	    lut_addr => lut_addr,
    	    lut_dout => lut_dout,
    	    --
    	    mem_clk => s_axi_aclk,
    	    mem_re => mem_re,
    	    mem_we => mem_we,
    	    --
    	    mem_addr => mem_addr,
    	    mem_din => mem_din,
    	    mem_dout => mem_dout );


    reg_rwseq_proc : process (
	s_axi_aclk, s_axi_areset_n,
	s_axi_ri, s_axi_wi, mem_dout )

	variable arready_v : std_logic := '0';
	variable rvalid_v : std_logic := '0';

	variable awready_v : std_logic := '0';
	variable wready_v : std_logic := '0';
	variable bvalid_v : std_logic := '0';

	variable rdata_v : std_logic_vector(31 downto 0);
	variable rresp_v : std_logic_vector(1 downto 0) := "00";

	variable wdata_v : std_logic_vector(31 downto 0);
	variable wstrb_v : std_logic_vector(3 downto 0);
	variable bresp_v : std_logic_vector(1 downto 0) := "00";

	type rw_state is (
	    idle_s,
	    r_addr_s, r_wait_s, r_data_s,
	    w_addr_s, w_data_s, w_resp_s );

	variable state : rw_state := idle_s;

    begin
	if rising_edge(s_axi_aclk) then
	    if s_axi_areset_n = '0' then
		mem_addr <= (others => '0');

		arready_v := '0';
		rvalid_v := '0';

		awready_v := '0';
		wready_v := '0';
		bvalid_v := '0';

		rdata_v := (others => '0');
		wdata_v := (others => '0');
		wstrb_v := (others => '0');

		state := idle_s;

	    else
		case state is
		    when idle_s =>
			rvalid_v := '0';
			bvalid_v := '0';

			mem_re <= '0';
			mem_we <= '0';

			if s_axi_ri.arvalid = '1' then	-- address valid
			    state := r_addr_s;

			elsif s_axi_wi.awvalid = '1' then -- address valid
			    state := w_addr_s;

			end if;

		--  ARVALID ---> RVALID		    Master
		--     \	 /`   \
		--	\,	/      \,
		--	 ARREADY     RREADY	    Slave

		    when r_addr_s =>
			mem_addr <= addr_f(araddr);

			-- mem_re(index_f(araddr)) <= '1';

			state := r_wait_s;

		    when r_wait_s =>
			arready_v := '1';		-- ready for transfer

			mem_re <= '1';

			state := r_data_s;

		    when r_data_s =>
			arready_v := '0';
			rresp_v := "00";

			if s_axi_ri.rready = '1' then
			    rvalid_v := '1';		-- response is valid

			    state := idle_s;
			end if;

		--  AWVALID ---> WVALID	 _	       BREADY	    Master
		--     \    --__ /`   \	  --__		/`
		--	\,	/--__  \,     --_      /
		--	 AWREADY     -> WREADY ---> BVALID	    Slave

		    when w_addr_s =>
			mem_addr <= addr_f(awaddr);

			awready_v := '1';		-- ready for transfer

			state := w_data_s;

		    when w_data_s =>
			awready_v := '0';		-- done with addr
			wready_v := '1';		-- ready for data

			if s_axi_wi.wvalid = '1' then	-- data transfer
			    wdata_v := s_axi_wi.wdata;
			    wstrb_v := s_axi_wi.wstrb;

			    mem_we <= '1';

			    bresp_v := "00";		-- transfer OK

			    state := w_resp_s;
			end if;

		    when w_resp_s =>
			wready_v := '0';		-- done with write

			if s_axi_wi.bready = '1' then	-- master ready
			    bvalid_v := '1';	-- response valid

			    state := idle_s;
			end if;

		end case;
	    end if;
	end if;

	mem_din <= wdata_v(DATA_WIDTH - 1 downto 0);

	s_axi_ro.arready <= arready_v;
	s_axi_ro.rvalid <= rvalid_v;

	s_axi_wo.awready <= awready_v;
	s_axi_wo.wready <= wready_v;
	s_axi_wo.bvalid <= bvalid_v;

	s_axi_ro.rdata <= (others => '0');
	s_axi_ro.rdata(DATA_WIDTH - 1 downto 0) <= mem_dout;
	s_axi_ro.rresp <= rresp_v;

	s_axi_wo.bresp <= bresp_v;

    end process;

end RTL;

----------------------------------------------------------------------------
--  reg_lut.vhd
--	AXI3 Lite BRAM LUT Interface
--	Version 1.4
--
--  SPDX-FileCopyrightText: © 2013 Herbert Poetzl <herbert@13thfloor.at>
--  SPDX-License-Identifier: GPL-2.0-or-later
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;

package lut_array_pkg is

    type lut_a is array (natural range <>) of
	std_logic_vector;

    type lut8_a is array (natural range <>) of
	std_logic_vector (7 downto 0);

    type lut9_a is array (natural range <>) of
	std_logic_vector (8 downto 0);

    type lut11_a is array (natural range <>) of
	std_logic_vector (10 downto 0);

    type lut12_a is array (natural range <>) of
	std_logic_vector (11 downto 0);

    type lut16_a is array (natural range <>) of
	std_logic_vector (15 downto 0);

    type lut18_a is array (natural range <>) of
	std_logic_vector (17 downto 0);

end lut_array_pkg;


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.helper_pkg.ALL;	-- Helpers
-- use work.minmax.ALL;		-- VHDL min/max
use work.lut_array_pkg.ALL;


entity reg_lutn is
    generic (
	DATA_WIDTH : natural := 9;
	ADDR_WIDTH : natural := 12;
	LUT_COUNT : natural := 4
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
	lut_addr : in std_logic_vector (LUT_COUNT * ADDR_WIDTH - 1 downto 0);
	lut_dout : out std_logic_vector (LUT_COUNT * DATA_WIDTH - 1 downto 0)
    );
end entity reg_lutn;


architecture RTL of reg_lutn is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant INDEX_WIDTH : natural := log2(LUT_COUNT) + 1;
    constant FULL_WIDTH : natural := ADDR_WIDTH + INDEX_WIDTH;

    signal mem_index : natural range 0 to LUT_COUNT - 1 := 0;
    signal mem_addr : std_logic_vector (ADDR_WIDTH - 1 downto 0);

    type mem_a is array (natural range <>) of
        std_logic_vector (DATA_WIDTH - 1 downto 0);

    signal mem_din : std_logic_vector (DATA_WIDTH - 1 downto 0);
    signal mem_dout : mem_a (0 to LUT_COUNT - 1);

    signal mem_we : std_logic_vector (0 to LUT_COUNT - 1)
	:= (others => '0');
    signal mem_re : std_logic_vector (0 to LUT_COUNT - 1)
	:= (others => '0');

    alias araddr: std_logic_vector (FULL_WIDTH - 1 downto 0)
	is s_axi_ri.araddr(FULL_WIDTH + 1 downto 2);
    alias awaddr: std_logic_vector (FULL_WIDTH - 1 downto 0)
	is s_axi_wi.awaddr(FULL_WIDTH + 1 downto 2);


    function addr_f ( val : std_logic_vector )
	return std_logic_vector is
    begin
	return val(ADDR_WIDTH - 1 downto 0);
    end function;


    function index_f ( val : std_logic_vector )
	return natural is
    begin
	return minimum(LUT_COUNT - 1,
	    to_index(val(val'high downto ADDR_WIDTH), INDEX_WIDTH));
    end function;

begin

    GEN_LUT: for I in 0 to LUT_COUNT - 1 generate
	alias slice_addr : std_logic_vector (ADDR_WIDTH - 1 downto 0) is
	    lut_addr(ADDR_WIDTH * (I + 1) - 1 downto ADDR_WIDTH * I);
	alias slice_dout : std_logic_vector (DATA_WIDTH - 1 downto 0) is
	    lut_dout(DATA_WIDTH * (I + 1) - 1 downto DATA_WIDTH * I);
    begin
	bram_lut_inst : entity work.bram_lut
	    generic map (
		DATA_WIDTH => DATA_WIDTH,
		ADDR_WIDTH => ADDR_WIDTH )
	    port map (
		lut_clk => lut_clk,
		lut_addr => slice_addr,
		lut_dout => slice_dout,
		--
		mem_clk => s_axi_aclk,
		mem_re => mem_re(I),
		mem_we => mem_we(I),
		--
		mem_addr => mem_addr,
		mem_din => mem_din,
		mem_dout => mem_dout(I) );

    end generate;

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
		mem_index <= 0;

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

			mem_re <= (others => '0');
			mem_we <= (others => '0');

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
			mem_index <= index_f(araddr);

			-- mem_re(index_f(araddr)) <= '1';

			state := r_wait_s;

		    when r_wait_s =>
			arready_v := '1';		-- ready for transfer

			mem_re(mem_index) <= '1';

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
			mem_index <= index_f(awaddr);

			awready_v := '1';		-- ready for transfer

			state := w_data_s;

		    when w_data_s =>
			awready_v := '0';		-- done with addr
			wready_v := '1';		-- ready for data

			if s_axi_wi.wvalid = '1' then	-- data transfer
			    wdata_v := s_axi_wi.wdata;
			    wstrb_v := s_axi_wi.wstrb;

			    mem_we(mem_index) <= '1';

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

	s_axi_ro.rdata(DATA_WIDTH - 1 downto 0) <= mem_dout(mem_index);
	s_axi_ro.rresp <= rresp_v;

	s_axi_wo.bresp <= bresp_v;

    end process;

end RTL;

------------------------------------------------------------------------
--	11 x 9 BRAM LUT
------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.helper_pkg.ALL;	-- Helpers
use work.lut_array_pkg.ALL;


entity reg_lut_11x9 is
    generic (
	LUT_COUNT : natural := 4
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
	lut_addr : in lut11_a (0 to LUT_COUNT - 1);
	lut_dout : out lut9_a (0 to LUT_COUNT - 1)
    );
end entity reg_lut_11x9;


architecture RTL of reg_lut_11x9 is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant ADDR_WIDTH : natural := 11;
    constant DATA_WIDTH : natural := 9;

    constant ADDRN_WIDTH : natural := LUT_COUNT * ADDR_WIDTH;
    constant DATAN_WIDTH : natural := LUT_COUNT * DATA_WIDTH;

    signal lutn_addr : std_logic_vector (ADDRN_WIDTH - 1 downto 0);
    signal lutn_dout : std_logic_vector (DATAN_WIDTH - 1 downto 0);

begin

    reg_lutn_inst : entity work.reg_lutn
	generic map (
	    DATA_WIDTH => DATA_WIDTH,
	    ADDR_WIDTH => ADDR_WIDTH,
	    LUT_COUNT => LUT_COUNT )
	port map (
	    s_axi_aclk => s_axi_aclk,
	    s_axi_areset_n => s_axi_areset_n,
	    --
	    s_axi_ro => s_axi_ro,
	    s_axi_ri => s_axi_ri,
	    s_axi_wo => s_axi_wo,
	    s_axi_wi => s_axi_wi,
	    --
	    lut_clk => lut_clk,
	    lut_addr => lutn_addr,
	    lut_dout => lutn_dout );

    GEN_LUT: for I in 0 to LUT_COUNT - 1 generate
    begin
	lutn_addr((I + 1) * ADDR_WIDTH - 1 downto I * ADDR_WIDTH)
	    <= lut_addr(I);
	lut_dout(I) <= slice(lutn_dout, DATA_WIDTH, I);
    end generate;

end RTL;

------------------------------------------------------------------------
--	11 x 12 BRAM LUT
------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.helper_pkg.ALL;	-- Helpers
use work.lut_array_pkg.ALL;


entity reg_lut_11x12 is
    generic (
	LUT_COUNT : natural := 4
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
	lut_addr : in lut11_a (0 to LUT_COUNT - 1);
	lut_dout : out lut12_a (0 to LUT_COUNT - 1)
    );
end entity reg_lut_11x12;


architecture RTL of reg_lut_11x12 is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant ADDR_WIDTH : natural := 11;
    constant DATA_WIDTH : natural := 12;

    constant ADDRN_WIDTH : natural := LUT_COUNT * ADDR_WIDTH;
    constant DATAN_WIDTH : natural := LUT_COUNT * DATA_WIDTH;

    signal lutn_addr : std_logic_vector (ADDRN_WIDTH - 1 downto 0);
    signal lutn_dout : std_logic_vector (DATAN_WIDTH - 1 downto 0);

begin

    reg_lutn_inst : entity work.reg_lutn
	generic map (
	    DATA_WIDTH => DATA_WIDTH,
	    ADDR_WIDTH => ADDR_WIDTH,
	    LUT_COUNT => LUT_COUNT )
	port map (
	    s_axi_aclk => s_axi_aclk,
	    s_axi_areset_n => s_axi_areset_n,
	    --
	    s_axi_ro => s_axi_ro,
	    s_axi_ri => s_axi_ri,
	    s_axi_wo => s_axi_wo,
	    s_axi_wi => s_axi_wi,
	    --
	    lut_clk => lut_clk,
	    lut_addr => lutn_addr,
	    lut_dout => lutn_dout );

    GEN_LUT: for I in 0 to LUT_COUNT - 1 generate
    begin
	lutn_addr((I + 1) * ADDR_WIDTH - 1 downto I * ADDR_WIDTH)
	    <= lut_addr(I);
	lut_dout(I) <= slice(lutn_dout, DATA_WIDTH, I);
    end generate;

end RTL;

------------------------------------------------------------------------
--	11 x 16 BRAM LUT
------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.helper_pkg.ALL;	-- Helpers
use work.lut_array_pkg.ALL;


entity reg_lut_11x16 is
    generic (
	LUT_COUNT : natural := 4
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
	lut_addr : in lut11_a (0 to LUT_COUNT - 1);
	lut_dout : out lut16_a (0 to LUT_COUNT - 1)
    );
end entity reg_lut_11x16;


architecture RTL of reg_lut_11x16 is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant ADDR_WIDTH : natural := 11;
    constant DATA_WIDTH : natural := 16;

    constant ADDRN_WIDTH : natural := LUT_COUNT * ADDR_WIDTH;
    constant DATAN_WIDTH : natural := LUT_COUNT * DATA_WIDTH;

    signal lutn_addr : std_logic_vector (ADDRN_WIDTH - 1 downto 0);
    signal lutn_dout : std_logic_vector (DATAN_WIDTH - 1 downto 0);

begin

    reg_lutn_inst : entity work.reg_lutn
	generic map (
	    DATA_WIDTH => DATA_WIDTH,
	    ADDR_WIDTH => ADDR_WIDTH,
	    LUT_COUNT => LUT_COUNT )
	port map (
	    s_axi_aclk => s_axi_aclk,
	    s_axi_areset_n => s_axi_areset_n,
	    --
	    s_axi_ro => s_axi_ro,
	    s_axi_ri => s_axi_ri,
	    s_axi_wo => s_axi_wo,
	    s_axi_wi => s_axi_wi,
	    --
	    lut_clk => lut_clk,
	    lut_addr => lutn_addr,
	    lut_dout => lutn_dout );

    GEN_LUT: for I in 0 to LUT_COUNT - 1 generate
    begin
	lutn_addr((I + 1) * ADDR_WIDTH - 1 downto I * ADDR_WIDTH)
	    <= lut_addr(I);
	lut_dout(I) <= slice(lutn_dout, DATA_WIDTH, I);
    end generate;

end RTL;

------------------------------------------------------------------------
--	12 x 12 BRAM LUT
------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.helper_pkg.ALL;	-- Helpers
use work.lut_array_pkg.ALL;


entity reg_lut_12x12 is
    generic (
	LUT_COUNT : natural := 4
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
	lut_addr : in lut12_a (0 to LUT_COUNT - 1);
	lut_dout : out lut12_a (0 to LUT_COUNT - 1)
    );
end entity reg_lut_12x12;


architecture RTL of reg_lut_12x12 is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant ADDR_WIDTH : natural := 12;
    constant DATA_WIDTH : natural := 12;

    constant ADDRN_WIDTH : natural := LUT_COUNT * ADDR_WIDTH;
    constant DATAN_WIDTH : natural := LUT_COUNT * DATA_WIDTH;

    signal lutn_addr : std_logic_vector (ADDRN_WIDTH - 1 downto 0);
    signal lutn_dout : std_logic_vector (DATAN_WIDTH - 1 downto 0);

begin

    reg_lutn_inst : entity work.reg_lutn
	generic map (
	    DATA_WIDTH => DATA_WIDTH,
	    ADDR_WIDTH => ADDR_WIDTH,
	    LUT_COUNT => LUT_COUNT )
	port map (
	    s_axi_aclk => s_axi_aclk,
	    s_axi_areset_n => s_axi_areset_n,
	    --
	    s_axi_ro => s_axi_ro,
	    s_axi_ri => s_axi_ri,
	    s_axi_wo => s_axi_wo,
	    s_axi_wi => s_axi_wi,
	    --
	    lut_clk => lut_clk,
	    lut_addr => lutn_addr,
	    lut_dout => lutn_dout );

    GEN_LUT: for I in 0 to LUT_COUNT - 1 generate
    begin
	lutn_addr((I + 1) * ADDR_WIDTH - 1 downto I * ADDR_WIDTH)
	    <= lut_addr(I);
	lut_dout(I) <= slice(lutn_dout, DATA_WIDTH, I);
    end generate;

end RTL;

------------------------------------------------------------------------
--	12 x 16 BRAM LUT
------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.helper_pkg.ALL;	-- Helpers
use work.lut_array_pkg.ALL;


entity reg_lut_12x16 is
    generic (
	LUT_COUNT : natural := 4
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
	lut_addr : in lut12_a (0 to LUT_COUNT - 1);
	lut_dout : out lut16_a (0 to LUT_COUNT - 1)
    );
end entity reg_lut_12x16;


architecture RTL of reg_lut_12x16 is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant ADDR_WIDTH : natural := 12;
    constant DATA_WIDTH : natural := 16;

    constant ADDRN_WIDTH : natural := LUT_COUNT * ADDR_WIDTH;
    constant DATAN_WIDTH : natural := LUT_COUNT * DATA_WIDTH;

    signal lutn_addr : std_logic_vector (ADDRN_WIDTH - 1 downto 0);
    signal lutn_dout : std_logic_vector (DATAN_WIDTH - 1 downto 0);

begin

    reg_lutn_inst : entity work.reg_lutn
	generic map (
	    DATA_WIDTH => DATA_WIDTH,
	    ADDR_WIDTH => ADDR_WIDTH,
	    LUT_COUNT => LUT_COUNT )
	port map (
	    s_axi_aclk => s_axi_aclk,
	    s_axi_areset_n => s_axi_areset_n,
	    --
	    s_axi_ro => s_axi_ro,
	    s_axi_ri => s_axi_ri,
	    s_axi_wo => s_axi_wo,
	    s_axi_wi => s_axi_wi,
	    --
	    lut_clk => lut_clk,
	    lut_addr => lutn_addr,
	    lut_dout => lutn_dout );

    GEN_LUT: for I in 0 to LUT_COUNT - 1 generate
    begin
	lutn_addr((I + 1) * ADDR_WIDTH - 1 downto I * ADDR_WIDTH)
	    <= lut_addr(I);
	lut_dout(I) <= slice(lutn_dout, DATA_WIDTH, I);
    end generate;

end RTL;

------------------------------------------------------------------------
--	12 x 18 BRAM LUT
------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.axi3ml_pkg.ALL;	-- AXI3 Lite Master
use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.helper_pkg.ALL;	-- Helpers
use work.lut_array_pkg.ALL;


entity reg_lut_12x18 is
    generic (
	LUT_COUNT : natural := 4
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
	lut_addr : in lut12_a (0 to LUT_COUNT - 1);
	lut_dout : out lut18_a (0 to LUT_COUNT - 1)
    );
end entity reg_lut_12x18;


architecture RTL of reg_lut_12x18 is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant ADDR_WIDTH : natural := 12;
    constant DATA_WIDTH : natural := 18;

    constant ADDRN_WIDTH : natural := LUT_COUNT * ADDR_WIDTH;
    constant DATAN_WIDTH : natural := LUT_COUNT * DATA_WIDTH;

    signal lutn_addr : std_logic_vector (ADDRN_WIDTH - 1 downto 0);
    signal lutn_dout : std_logic_vector (DATAN_WIDTH - 1 downto 0);

begin

    reg_lutn_inst : entity work.reg_lutn
	generic map (
	    DATA_WIDTH => DATA_WIDTH,
	    ADDR_WIDTH => ADDR_WIDTH,
	    LUT_COUNT => LUT_COUNT )
	port map (
	    s_axi_aclk => s_axi_aclk,
	    s_axi_areset_n => s_axi_areset_n,
	    --
	    s_axi_ro => s_axi_ro,
	    s_axi_ri => s_axi_ri,
	    s_axi_wo => s_axi_wo,
	    s_axi_wi => s_axi_wi,
	    --
	    lut_clk => lut_clk,
	    lut_addr => lutn_addr,
	    lut_dout => lutn_dout );

    GEN_LUT: for I in 0 to LUT_COUNT - 1 generate
    begin
	lutn_addr((I + 1) * ADDR_WIDTH - 1 downto I * ADDR_WIDTH)
	    <= lut_addr(I);
	lut_dout(I) <= slice(lutn_dout, DATA_WIDTH, I);
    end generate;

end RTL;

------------------------------------------------------------------------
--  pixel_remap.vhd
--  v2.0
--
--  Copyright (C) 2013 M.FORET
--
--  This program is free software: you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation, either version
--  2 of the License, or (at your option) any later version.
------------------------------------------------------------------------

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- CMV12000 sensor outputs pixels line by line but in 1 line it can output
-- more than 1 pixel/clk, there are up to 32 outputs (lanes)
-- Positions of the lanes in the line depends of the number of lanes
-- and they are at the same distance of each other, for example in the
-- case of 16 lanes, positions are:
--   0, 256, 512, 768, 1024, 1280, 1536, 1792, 2048, 2304, 2560, 2816
--   3072, 3328, 3584, 3840
-- So at each clock we get 16 pixels but they are not adjacent, to solve
-- this problem we are going to write pixels in a memory and at the end
-- of the line we read the pixels in the good order
--
-- In order to save RAM ressources and simplify muxes, there are
-- optimizations but number of lanes must be multiple of 4
-- Number of RAM used = nb_of_lanes / 4 + 1
--
-- Example for a line of 32 pixels with 8 lanes (8 pixels/lane)
--
-- Output of each lane:
-- clk	  : _|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|
-- dv_par : _|---|___|---|___|---|___|---|___|---|___|---|___|---|___|
-- lane 0 :   0	      1	      2	      3	      4	      5	      6
-- lane 1 :   8	      9	      10      11      12      13      14
-- lane 2 :   16      17      18      19      20      21      22
-- lane 3 :   24      25      26      27      28      29      30
-- lane 4 :   32      33      34      35      36      37      38
--  ...
-- lane 7 :   56      57      58      59      60      61      62
--
-- Writing
-- clk	  : _|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|
-- addr	  :		  0   4	  8   12  1   5	  9   13  2   6	  10
--	   -------------------------------------------------------------
-- mem 0  :		  0   8	  16  24  2   10  18  26  36  44  52
--			  1   9	  17  25  3   11  19  27  37  45  53
-- mem 1  :		  32  40  48  56  34  42  50  58  4   12  20
--			  33  41  49  57  35  43  51  59  5   13  21
--
--
-- Writing sequence
--	     0	1  2  3	 4  5  6  7  8	9 10 11 12 13 14 15 16
-- -----------------------------------------------------------
-- address | 0		 1	     2		3	    -
-- -----------------------------------------------------------
-- ram0	   | 0,1	 2,3	     36,37	38,39
-- ram1	   | 32,33	 34,35	     4,5	6,7
-- ...
-- -----------------------------------------------------------
-- address | 12		 13	     14		15	     -
-- -----------------------------------------------------------
-- ram0	   | 24,25	 26,27	     60,61	62,63
-- ram1	   | 56,57	 58,59	     28,29	30,31
--
--
-- Reading sequence (1,0 means ram1 and address 0)
--	  t0	t1    t2    t3	  t4	t5    t6    t7	  t8
--  clk	   |  |	 |  |  |  |  |	|  |  |	 |  |  |  |  |	|  |
-- -----------------------------------------------------------
-- out0 | 0,0	0,4   0,8   0,12  1,0	1,4   1,8   1,12  -
-- out1 | 0,0	0,4   0,8   0,12  1,0	1,4   1,8   1,12  -
-- out2 | 0,1	0,5   0,9   0,13  1,1	1,5   1,9   1,13  -
-- out3 | 0,1	0,5   0,9   0,13  1,1	1,5   1,9   1,13  -
-- out4 | 1,2	1,6   1,10  1,14  0,2	0,6   0,10  0,14  -
-- out5 | 1,2	1,6   1,10  1,14  0,2	0,6   0,10  0,14  -
-- out6 | 1,3	1,7   1,11  1,15  0,3	0,7   0,11  0,15  -
-- out7 | 1,3	1,7   1,11  1,15  0,3	0,7   0,11  0,15  -
--
--
-- Before being able to ouput data it is necessary to wait 1 line,
-- this delay is made with a RAM that we start to read at the end of the
-- first line of the frame
--
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.par_array_pkg.ALL;	-- Parallel Data
use work.vivado_pkg.ALL;	-- Vivado Attributes


entity pixel_remap is
    generic (
	NB_LANES   : positive := 16 );
    port (
	clk	   : in	 std_logic;

	dv_par	   : in	 std_logic;		-- data valid according to clk
	ctrl_in	   : in	 std_logic_vector (12 - 1 downto 0);
	par_din	   : in	 par12_a (NB_LANES-1 downto 0);

	ctrl_out   : out std_logic_vector (12 - 1 downto 0);
	par_dout   : out par12_a (NB_LANES-1 downto 0) );
end entity;


architecture RTL of pixel_remap is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    constant DATA_WIDTH : positive := 12;

    function log2(val : natural) return natural is
	variable res : natural;
    begin
	for i in 30 downto 0 loop
	    if val > (2 ** i) then
		res := i;
		exit;
	    end if;
	end loop;
	return (res + 1);
    end function;

    constant NB_LANES_WIDTH	: positive := log2(NB_LANES);
    constant SIZE_LINE		: positive := 4096 / (NB_LANES*2);
    constant ADDR_WIDTH		: positive := log2(SIZE_LINE);
    constant ADDR_WIDTH_SYNC	: positive := 10;

    constant NB_MEM		: positive := NB_LANES / 4;

    signal din	      : std_logic_vector(NB_LANES * DATA_WIDTH - 1 downto 0);
    signal dout	      : std_logic_vector(NB_LANES * DATA_WIDTH - 1 downto 0);

    type sel_mem_t is array (natural range <>) of
	unsigned(NB_LANES_WIDTH-2 - 1 downto 0);

    signal sel_wr   : sel_mem_t(NB_MEM - 1 downto 0);

    type vect_data is array (natural range <>) of
	std_logic_vector(DATA_WIDTH - 1 downto 0);

    type vect_data2 is array (natural range <>) of
	std_logic_vector(2 * DATA_WIDTH - 1 downto 0);

    signal wr_data    : vect_data2(NB_MEM - 1 downto 0);
    signal data2wr    : vect_data2(NB_LANES - 1 downto 0);
    signal rd_data    : vect_data2(NB_MEM - 1 downto 0);
    signal data2rd    : vect_data2(NB_MEM - 1 downto 0);

    signal data2out   : vect_data(NB_LANES - 1 downto 0);

    type vect_addr is array (natural range <>) of
	unsigned(ADDR_WIDTH+1  downto 0);

    signal addr	    : vect_addr(NB_MEM - 1 downto 0);
    signal addr_rd  : vect_addr(NB_MEM - 1 downto 0);

    type vect_addr1 is array (natural range <>) of
	unsigned(ADDR_WIDTH+2 downto 0);

    signal mem_addr_rd : vect_addr1(NB_MEM - 1 downto 0);

    signal fval1       : std_logic := '0';
    signal lval1       : std_logic := '0';
    signal dval1       : std_logic := '0';
    signal fval2       : std_logic := '0';
    signal lval2       : std_logic := '0';
    signal dval2       : std_logic := '0';

    signal din1	       : vect_data(NB_LANES - 1 downto 0);
    signal count_clk   : unsigned( 1 downto 0) := (others => '0');

    signal addr_wr     : unsigned(ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal msb_addr_wr : unsigned(1 downto 0) := "00";
    signal z_addr_wr   : std_logic := '0';
    signal mem_addr_wr : unsigned(ADDR_WIDTH + 2 downto 0) := (others => '0');
    signal wea	       : std_logic_vector(0 downto 0);

    signal count_rd    : unsigned(0 downto 0) := "0";
    signal count_rd1   : unsigned(0 downto 0) := "0";
    signal z_addr_rd   : std_logic := '0';
    signal sel_mem     : unsigned(NB_LANES_WIDTH-2 - 1 downto 0);
    signal sel_rd      : unsigned(NB_LANES_WIDTH-2 - 1 downto 0);
    signal sel_rd1     : unsigned(NB_LANES_WIDTH-2 - 1 downto 0);
    signal sel_rd2     : unsigned(NB_LANES_WIDTH-2 - 1 downto 0);

    signal addr_wr_sync : unsigned(ADDR_WIDTH_SYNC - 1 downto 0);
    signal addr_rd_sync : unsigned(ADDR_WIDTH_SYNC - 1 downto 0);
    signal wea_sync	: std_logic_vector(0 downto 0);
    signal din_sync	: std_logic_vector(1 downto 0);
    signal dout_sync	: std_logic_vector(1 downto 0);
    signal read_sync	: std_logic := '0';
    signal read_sync1	: std_logic := '0';
    signal read_sync2	: std_logic := '0';
    signal fval_rd	: std_logic := '0';
    signal lval_rd	: std_logic := '0';
    signal dval_rd	: std_logic := '0';
    signal fval_delay	: std_logic_vector(2 downto 0);
    signal lval_delay	: std_logic_vector(2 downto 0);
    signal dval_delay	: std_logic_vector(2 downto 0);

    --

    alias fval_in	: std_logic is ctrl_in(2);
    alias lval_in	: std_logic is ctrl_in(1);
    alias dval_in	: std_logic is ctrl_in(0);

    alias fval_out	: std_logic is ctrl_out(2);
    alias lval_out	: std_logic is ctrl_out(1);
    alias dval_out	: std_logic is ctrl_out(0);

begin

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- conversion std_logic_vector <-> array

    gen_din : for I in NB_LANES - 1 downto 0 generate
	din((I + 1) * DATA_WIDTH - 1 downto I * DATA_WIDTH) <=
	   par_din(I);
    end generate;

    gen_dout : for I in NB_LANES-1 downto 0 generate
	par_dout(I) <=
	    dout((I + 1) * DATA_WIDTH - 1 downto I * DATA_WIDTH);
    end generate;


    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- writing into RAM

    process (clk)
    begin
	if rising_edge(clk) then
	    if dv_par = '1' then
		dval1 <= dval_in;
		lval1 <= lval_in;
		fval1 <= fval_in;
		dval2 <= dval1;
		lval2 <= lval1;
		fval2 <= fval1;
	    end if;
	end if;
    end process;

    process (clk)
    begin
	if rising_edge(clk) then
	    if dv_par = '1' then
		for i in 0 to NB_LANES - 1 loop
		    din1(i) <=
			din((i + 1) * DATA_WIDTH - 1 downto i * DATA_WIDTH);
		end loop;
	    end if;
	end if;
    end process;

    -- counter for cycle of 4 clk
    process (clk)
    begin
	if rising_edge(clk) then
	    if dval2 = '0' then
		count_clk <= (others => '0');
	    else
		count_clk <= count_clk + 1;
	    end if;
	end if;
    end process;

    -- concatenate 2 pixels / lane
    process (clk)
    begin
	if rising_edge(clk) then
	    if count_clk = 3 or dval2 = '0' then
		for i in 0 to NB_LANES - 1 loop
		    data2wr(i) <=
			din((i + 1) * DATA_WIDTH - 1 downto i * DATA_WIDTH) & din1(i);
		end loop;
	    end if;
	end if;
    end process;

    -- compute address that is going to be used for 4 lanes
    process (clk)
    begin
	if rising_edge(clk) then
	    if lval2 = '0' then
		addr_wr <= (others => '0');

	    elsif count_clk = 3 then
		addr_wr <= addr_wr + 1;

	    end if;
	end if;
    end process;

    -- write at different address for each lane
    msb_addr_wr <= "00" when (count_clk=0) else
		   "01" when (count_clk=1) else
		   "10" when (count_clk=2) else
		   "11";

    -- switch memory zone at the end of each line
    process (clk)
    begin
	if rising_edge(clk) then
	    if dv_par = '1' then
		if fval1 = '0' then
		    z_addr_wr <= '0';

		elsif lval1 = '0' and lval2 = '1' then
		    z_addr_wr <= not z_addr_wr;

		end if;
	    end if;
	end if;
    end process;

    -- calculate which lane to assign to RAM 0 .. NB_LANES - 1
    process (clk)
	variable sel : unsigned(NB_LANES_WIDTH-1 - 1 downto 0)
	    := (others => '0');
    begin
	if rising_edge(clk) then
	    if lval2 = '0' then
		sel := (others => '0');

	    elsif count_clk = 3 then
		sel := sel -1;

	    end if;

	    for i in 0 to NB_MEM - 1 loop
		if sel(0) = '0' then
		    sel_wr(i) <= sel(sel'high downto 1) + i;
		end if;
	    end loop;
	end if;
    end process;

    -- final address : zone, address for lane, address
    process (clk)
	variable sel : natural;
    begin
	if rising_edge(clk) then
	    mem_addr_wr <= z_addr_wr & msb_addr_wr & addr_wr;
	end if;
    end process;

    -- write enable
    process (clk)
	variable sel : natural;
    begin
	if rising_edge(clk) then
	    if dval2 = '1' then
		    wea <= (others => '1');
	    else
		    wea <= (others => '0');
	    end if;
	end if;
    end process;

    gen_data_wr: for i in 0 to NB_MEM - 1 generate

	-- select data according to the lane
	process (clk)
	    variable sel : natural;
	begin
	    if rising_edge(clk) then
		sel := to_integer(sel_wr(i));
		case msb_addr_wr is
		    when "00"	=> wr_data(i) <= data2wr(4 * sel + 0);
		    when "01"	=> wr_data(i) <= data2wr(4 * sel + 1);
		    when "10"	=> wr_data(i) <= data2wr(4 * sel + 2);
		    when "11"	=> wr_data(i) <= data2wr(4 * sel + 3);
		    when others => wr_data(i) <= (others => 'U');
		end case;
	    end if;
	end process;

    end generate;

--  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  reading from RAM

    -- counter for cycle : 2 clk / data
    process (clk)
    begin
	if rising_edge(clk) then
	    if dval_rd = '0' then
		count_rd <= (others => '0');
	    else
		count_rd <= count_rd + 1;
	    end if;
	end if;
    end process;

    -- compute addr at each clk and for each RAM
    process (clk)
	variable sel : unsigned(ADDR_WIDTH + 1 downto 0) := (others => '0');
    begin
	if rising_edge(clk) then
	    --if dv_par = '1' then
	    if count_rd = 1 or dval_rd = '0' then
		if lval_rd = '0' then
		    sel := (others => '0');

		elsif dval_rd = '1' then
		    sel := sel + 2 * NB_MEM;

		end if;
	    end if;

	    for i in 0 to NB_MEM - 1 loop
		if count_rd = 1 or dval_rd = '0' then
			addr(i) <= sel + 2 * i;
		else
			addr(i) <= sel + 2 * i + 1;
		end if;
	    end loop;
	end if;
    end process;

    -- calculate pointer for address and data
    process (clk)
	variable cnt_lane  : unsigned(ADDR_WIDTH + 1 downto 0) := (others => '0');
    begin
	if rising_edge(clk) then
	    if dv_par = '1' then
		if lval_rd = '0' then
		    cnt_lane := (others => '0');
		    sel_mem <= (others => '0');
		    sel_rd  <= (others => '0');

		elsif dval_rd = '1' then
		    cnt_lane := cnt_lane + 2 * NB_MEM;

		    if cnt_lane = 0 then
			sel_mem <= sel_mem - 1;
			sel_rd	<= sel_rd + 1;
		    end if;
		end if;
	    end if;
	end if;
    end process;

    -- assign reading address to each RAM
    gen_addr_rd: for i in 0 to NB_MEM - 1 generate
	process (clk)
	    variable sel : unsigned(NB_LANES_WIDTH - 2 - 1 downto 0);
	begin
	    if rising_edge(clk) then
		--if dv_par = '1' then
		    sel := sel_mem + i;
		    addr_rd(i) <= addr(to_integer(sel));
		--end if;
	    end if;
	end process;
    end generate;


    -- update zone when a new line starts
    process (clk)
    begin
	if rising_edge(clk) then
	    if dv_par = '1' then
		if lval_rd = '0' then
		    --z_addr_rd <= not(z_addr_wr);
		    z_addr_rd <= z_addr_wr;
		end if;
	    end if;
	end if;
    end process;

    gen_mem_addr_rd: for i in 0 to NB_MEM - 1 generate
	mem_addr_rd(i) <= z_addr_rd & addr_rd(i);
    end generate;

    -- latency of RAM reading
    process (clk)
    begin
	if rising_edge(clk) then
	    if dv_par = '1' then
		sel_rd1 <= sel_rd;
		sel_rd2 <= sel_rd1;
		count_rd1 <= count_rd;
	    end if;
	end if;
    end process;

    -- assign data output of each RAM to 1 output
    gen_out: for i in 0 to NB_MEM - 1 generate

	-- latch data on first clk
	process (clk)
	begin
	    if rising_edge(clk) then
		--if count_rd = 1 then
		if count_rd1 = 1 then
		    data2rd(i) <= rd_data(i);
		end if;
	    end if;
	end process;

	-- latch data read on each clk
	process (clk)
	    variable sel : unsigned(NB_LANES_WIDTH - 2 - 1 downto 0);
	begin
	    if rising_edge(clk) then
		if dv_par = '0' then
		    --sel := sel_rd + i;
		    sel := sel_rd2 + i;
		    data2out(4 * i + 0) <= data2rd(to_integer(sel))(1 * DATA_WIDTH - 1 downto 0 * DATA_WIDTH);
		    data2out(4 * i + 1) <= data2rd(to_integer(sel))(2 * DATA_WIDTH - 1 downto 1 * DATA_WIDTH);
		    data2out(4 * i + 2) <= rd_data(to_integer(sel))(1 * DATA_WIDTH - 1 downto 0 * DATA_WIDTH);
		    data2out(4 * i + 3) <= rd_data(to_integer(sel))(2 * DATA_WIDTH - 1 downto 1 * DATA_WIDTH);
		end if;
	    end if;
	end process;

	-- data for output
	process (clk)
	begin
	    if rising_edge(clk) then
		if dv_par = '1' then
		    dout((4 * i + 0 + 1) * DATA_WIDTH - 1 downto (4 * i + 0) * DATA_WIDTH) <= data2out(4 * i + 0);
		    dout((4 * i + 1 + 1) * DATA_WIDTH - 1 downto (4 * i + 1) * DATA_WIDTH) <= data2out(4 * i + 1);
		    dout((4 * i + 2 + 1) * DATA_WIDTH - 1 downto (4 * i + 2) * DATA_WIDTH) <= data2out(4 * i + 2);
		    dout((4 * i + 3 + 1) * DATA_WIDTH - 1 downto (4 * i + 3) * DATA_WIDTH) <= data2out(4 * i + 3);
		end if;
	    end if;
	end process;

    end generate;



--  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  manage delay with input sync, wait 1 line before starting to read

    -- writing pointer
    process (clk)
    begin
	if rising_edge(clk) then
	    if dv_par = '1' then
		if fval_in = '0' and read_sync = '0' then
		    addr_wr_sync <= (others => '0');

		elsif fval_in = '1' then
		    addr_wr_sync <= addr_wr_sync + 1;

		end if;
	    end if;
	end if;
    end process;

    -- reading pointer
    process (clk)
    begin
	if rising_edge(clk) then
	    if dv_par = '1' then
		if read_sync = '0' then
		    addr_rd_sync <= (others => '0');

		else
		    addr_rd_sync <= addr_rd_sync + 1;

		end if;
	    end if;
	end if;
    end process;

    wea_sync <= (others => fval_in) when dv_par = '1' else (others => '0');
    din_sync <= lval_in & dval_in;

    -- start read after the 1rst line of frame and stop when pointers are equal
    process (clk)
    begin
	if rising_edge(clk) then
	    if dv_par = '1' then
		if lval_in = '0' and fval_in = '1' then
		    read_sync <= '1';

		elsif addr_wr_sync = addr_rd_sync then
		    read_sync <= '0';

		end if;
		--
		read_sync1 <= read_sync;
		read_sync2 <= read_sync1;
	    end if;
	end if;
    end process;

    -- mask ouput of RAM when they are not valid
    fval_rd <= read_sync1 and read_sync;
    lval_rd <= dout_sync(1) and read_sync1 and read_sync;
    dval_rd <= dout_sync(0) and read_sync1 and read_sync;

    ram_sync0 : entity work.ram_sdp_reg
	generic map (
	    DATA_WIDTH => 2,
	    ADDR_WIDTH => ADDR_WIDTH_SYNC )
	port map (
	    clka   => clk,
	    ena	   => '1',
	    wea	   => wea_sync,
	    addra  => std_logic_vector(addr_wr_sync),
	    dina   => din_sync,
	    clkb   => clk,
	    enb	   => '1',
	    addrb  => std_logic_vector(addr_rd_sync),
	    reg_ce => dv_par,
	    doutb  => dout_sync );

--  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--  output (delay due to RAM latency and address calculation)

    process (clk)
    begin
	if rising_edge(clk) then
	    if dv_par = '1' then
		fval_delay <= fval_delay(fval_delay'high - 1 downto 0) & fval_rd;
		dval_delay <= dval_delay(dval_delay'high - 1 downto 0) & dval_rd;
		lval_delay <= lval_delay(lval_delay'high - 1 downto 0) & lval_rd;
	    end if;
	end if;
    end process;

    fval_out <= fval_delay(fval_delay'high);
    lval_out <= lval_delay(lval_delay'high);
    dval_out <= dval_delay(dval_delay'high);

    -- at the moment others information of control channel are not transmitted
    ctrl_out(ctrl_out'high downto 3) <= (others => '0');

    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    gen_all_mem: for i in 0 to NB_MEM - 1 generate
	ram_data0 : entity work.ram_sdp_reg
	    generic map (
		DATA_WIDTH => 2 * DATA_WIDTH,
		ADDR_WIDTH => ADDR_WIDTH + 3 )
	    port map (
		clka   => clk,
		ena    => '1',
		wea    => wea,
		addra  => std_logic_vector(mem_addr_wr),
		dina   => wr_data(i),
		clkb   => clk,
		enb    => '1',
		addrb  => std_logic_vector(mem_addr_rd(i)),
		reg_ce => '1',
		doutb  => rd_data(i) );
    end generate;

end RTL;

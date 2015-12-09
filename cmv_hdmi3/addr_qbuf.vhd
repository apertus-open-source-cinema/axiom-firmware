----------------------------------------------------------------------------
--  addr_qbuf.vhd
--	Quadruple Buffer Address Generator
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

use work.vivado_pkg.ALL;	-- Vivado Attributes


entity addr_qbuf is
    generic (
	COUNT_WIDTH : natural := 12;
	ADDR_WIDTH : natural := 32 );
    port (
	clk	: in std_logic;		-- base clock
	reset	: in std_logic;		-- reset to first buffer
	load	: in std_logic;		-- load buffer address
	enable	: in std_logic;		-- enable address increment
	--
	sel_in	: in std_logic_vector (1 downto 0);
	switch	: in std_logic;		-- switch to buffer
	--
	buf0_addr : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	buf1_addr : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	buf2_addr : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	buf3_addr : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	col_inc : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	col_cnt : in std_logic_vector (COUNT_WIDTH - 1 downto 0);
	--
	row_inc : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	buf0_epat : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	buf1_epat : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	buf2_epat : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	buf3_epat : in std_logic_vector (ADDR_WIDTH - 1 downto 0);
	--
	addr	: out std_logic_vector (ADDR_WIDTH - 1 downto 0);
	match	: out std_logic;
	sel	: out std_logic_vector (1 downto 0)
    );

end entity addr_qbuf;


architecture RTL of addr_qbuf is

    -- attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal epat_match : std_logic;
    signal agen_load : std_logic;

    signal buf_sel : unsigned (1 downto 0) := (others => '0');

    signal buf_addr : std_logic_vector (ADDR_WIDTH - 1 downto 0)
	:= (others => '0');
    signal buf_epat : std_logic_vector (ADDR_WIDTH - 1 downto 0)
	:= (others => '0');

begin

    buf_sel_proc: process (clk)
    begin
	if rising_edge(clk) then
	    if reset = '1' then
		buf_sel <= (others => '0');

	    elsif switch = '1' then
		buf_sel <= unsigned(sel_in);

	    elsif enable = '1' then
		if epat_match = '1' then
		    buf_sel <= buf_sel + "1";
		end if;
	    end if;
	end if;
    end process;

    buf_addr <=
	buf0_addr when buf_sel = "00" else
	buf1_addr when buf_sel = "01" else
	buf2_addr when buf_sel = "10" else
	buf3_addr;

    buf_epat <=
	buf0_epat when buf_sel = "00" else
	buf1_epat when buf_sel = "01" else
	buf2_epat when buf_sel = "10" else
	buf3_epat;

    agen_load <= load or reset;

    addr_gen_inst : entity work.addr_gen
	generic map (
	    COUNT_WIDTH => COUNT_WIDTH,
	    ADDR_WIDTH => ADDR_WIDTH )
	port map (
	    clk => clk,
	    load => agen_load,
	    enable => enable,
	    --
	    addr_in => buf_addr,
	    --
	    col_inc => col_inc,
	    col_cnt => col_cnt,
	    --
	    row_inc => row_inc,
	    --
	    pattern => buf_epat,
	    --
	    addr => addr,
	    match => epat_match );

    match <= epat_match;
    sel <= std_logic_vector(buf_sel);

end RTL;

----------------------------------------------------------------------------
--  scan_pong.vhd
--	Scan Generator for PONG
--	Version 1.0
--
--  Copyright (C) 2014 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;

package pong_pkg is

    type pong_block_r is record
	hpos_s	: std_logic_vector (11 downto 0);
	hpos_e	: std_logic_vector (11 downto 0);
	vpos_s	: std_logic_vector (11 downto 0);
	vpos_e	: std_logic_vector (11 downto 0);
	color	: std_logic_vector (31 downto 0);
    end record;

    type pong_score_r is record
	hpos	: std_logic_vector (11 downto 0);
	vpos	: std_logic_vector (11 downto 0);
	mask	: std_logic_vector (31 downto 0);
	color	: std_logic_vector (31 downto 0);
    end record;

end;


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.pong_pkg.ALL;		-- PONG Record

entity scan_pong is
    port (
	clk	: in std_logic;				-- Scan CLK
	reset_n	: in std_logic;				-- # Reset
	--
	hcnt_in	: in std_logic_vector(11 downto 0);
	vcnt_in	: in std_logic_vector(11 downto 0);
	fcnt_in	: in std_logic_vector(11 downto 0);
	--
	data_eo	: in std_logic;
	--
	left	: in pong_block_r;
	right	: in pong_block_r;
	ball	: in pong_block_r;
	net	: in pong_block_r;
	--
	lscore	: in pong_score_r;
	rscore	: in pong_score_r;
	--
	overlay	: out std_logic;
	color	: out std_logic_vector(31 downto 0)
    );
end entity scan_pong;


architecture RTL of scan_pong is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal vcnt_mask : std_logic_vector (11 downto 0);

    signal flags_left : std_logic_vector (3 downto 0);
    signal flags_right : std_logic_vector (3 downto 0);
    signal flags_ball : std_logic_vector (3 downto 0);

    signal flags_net : std_logic_vector (3 downto 0);

begin

    scan_comp_inst0 : entity work.scan_comp
	port map (
	    clk => clk,
	    reset_n => reset_n,
	    --
	    a0 => left.hpos_s,
	    a1 => left.hpos_e,
	    a2 => left.vpos_s,
	    a3 => left.vpos_e,
	    --
	    b0 => hcnt_in,
	    b1 => hcnt_in,
	    b2 => vcnt_in,
	    b3 => vcnt_in,
	    --
	    flags => flags_left );

    scan_comp_inst1 : entity work.scan_comp
	port map (
	    clk => clk,
	    reset_n => reset_n,
	    --
	    a0 => right.hpos_s,
	    a1 => right.hpos_e,
	    a2 => right.vpos_s,
	    a3 => right.vpos_e,
	    --
	    b0 => hcnt_in,
	    b1 => hcnt_in,
	    b2 => vcnt_in,
	    b3 => vcnt_in,
	    --
	    flags => flags_right );

    scan_comp_inst2 : entity work.scan_comp
	port map (
	    clk => clk,
	    reset_n => reset_n,
	    --
	    a0 => ball.hpos_s,
	    a1 => ball.hpos_e,
	    a2 => ball.vpos_s,
	    a3 => ball.vpos_e,
	    --
	    b0 => hcnt_in,
	    b1 => hcnt_in,
	    b2 => vcnt_in,
	    b3 => vcnt_in,
	    --
	    flags => flags_ball );

    vcnt_mask <= "0000000" & vcnt_in(4 downto 0);

    scan_comp_inst3 : entity work.scan_comp
	port map (
	    clk => clk,
	    reset_n => reset_n,
	    --
	    a0 => net.hpos_s,
	    a1 => net.hpos_e,
	    a2 => net.vpos_s,
	    a3 => net.vpos_e,
	    --
	    b0 => hcnt_in,
	    b1 => hcnt_in,
	    b2 => vcnt_mask,
	    b3 => vcnt_mask,
	    --
	    flags => flags_net );

    overlay_proc : process(clk)

	variable left_v : std_logic := '0';
	variable right_v : std_logic := '0';
	variable ball_v : std_logic := '0';
	variable net_v : std_logic := '0';

	variable lscore_v : std_logic := '0';
	variable rscore_v : std_logic := '0';

	function score_f (
	    mask : std_logic_vector (31 downto 0);
	    hcnt : unsigned (11 downto 0);
	    vcnt : unsigned (11 downto 0);
	    hpos : unsigned (11 downto 0);
	    vpos : unsigned (11 downto 0) )
	    return std_logic is
	
	    variable hbc_v : integer := to_integer(hcnt - hpos) / 16;
	    variable vbc_v : integer := to_integer(vcnt - vpos) / 16;
	
	    variable mask_v : std_logic_vector (63 downto 0) :=
		"0" & mask(31) & mask(31) & mask(31) & mask(31) & mask(31) &
		    mask(31) & mask(31) & mask(31) & mask(31) &
		mask(15) & mask(30 downto 28) & mask(15) &
		    mask(14 downto 12) & mask(15) &
		mask(15) & mask(27 downto 25) & mask(15) &
		    mask(11 downto 9) & mask(15) &
		mask(15) & mask(24 downto 22) & mask(15) &
		    mask(8 downto 6) &  mask(15) &
		mask(15) & mask(21 downto 19) & mask(15) &
		    mask(5 downto 3) &  mask(15) &
		mask(15) & mask(18 downto 16) & mask(15) &
		    mask(2 downto 0) &  mask(15) &
		mask(31) & mask(31) & mask(31) & mask(31) & mask(31) &
		    mask(31) & mask(31) & mask(31) & mask(31);
	begin
	    if (hbc_v >= 0) and (hbc_v < 9) then
		if (vbc_v >= 0) and (vbc_v < 7) then
		    return mask_v(hbc_v + vbc_v * 9);
		end if;
	    end if;
	    return '0';
	end function;

    begin
	if rising_edge(clk) then
	    if lscore_v = '1' then
		color <= lscore.color;
	    elsif rscore_v = '1' then
		color <= rscore.color;
	    elsif ball_v = '1' then
		color <= ball.color;
	    elsif left_v = '1' then
		color <= left.color;
	    elsif right_v = '1' then
		color <= right.color;
	    elsif net_v = '1' then
		color <= net.color;
	    else 
		color <= (others => '0');
	    end if;

	    overlay <= ball_v or left_v or right_v or net_v or
		lscore_v or rscore_v;

	    left_v :=
		(flags_left(0) xor flags_left(1)) and
		(flags_left(2) xor flags_left(3));
	    right_v :=
		(flags_right(0) xor flags_right(1)) and
		(flags_right(2) xor flags_right(3));
	    ball_v :=
		(flags_ball(0) xor flags_ball(1)) and
		(flags_ball(2) xor flags_ball(3));
	    net_v :=
		(flags_net(0) xor flags_net(1)) and
		(flags_net(2) xor flags_net(3));

	    lscore_v := score_f(lscore.mask,
		unsigned(hcnt_in), unsigned(vcnt_in),
		unsigned(lscore.hpos), unsigned(lscore.vpos));
	    rscore_v := score_f(rscore.mask,
		unsigned(hcnt_in), unsigned(vcnt_in),
		unsigned(rscore.hpos), unsigned(rscore.vpos));
	end if;
    end process;

end RTL;

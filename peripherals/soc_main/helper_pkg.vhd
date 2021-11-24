----------------------------------------------------------------------------
--  helper_pkg.vhd
--	Various Helper Functions
--	Version 1.1
--
--  SPDX-FileCopyrightText: © 2014 Herbert Poetzl <herbert@13thfloor.at>
--  SPDX-License-Identifier: GPL-2.0-or-later
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;


package helper_pkg is

    function log2( val : natural )
	return integer;


    function slice (
	val : std_logic_vector;
	width, num : natural )
	return std_logic_vector;


    function to_index (
	val : std_logic_vector )
	return natural;

    function to_index (
	val : std_logic_vector;
	len : natural )
	return natural;


    function to_addr (
	val, len : natural )
	return std_logic_vector;

end helper_pkg;


package body helper_pkg is


    function log2( val : natural )
	return integer is

	variable temp : integer := val;
	variable ret  : integer := 0;
    begin
	while temp > 1 loop
	    ret := ret + 1;
	    temp := temp / 2;
	end loop;

	return ret;
    end function;


    function slice (
	val : std_logic_vector;
	width, num : natural )
	return std_logic_vector is
    begin
	return val(width * (num + 1) - 1 downto width * num);
    end function;


    function to_index (
	val : std_logic_vector )
	return natural is
    begin
	return to_integer(unsigned(val));
    end function;


    function to_index (
	val : std_logic_vector;
	len : natural )
	return natural is

	constant high_c : natural := val'low + len - 1;
    begin
	assert high_c <= val'high
	    report "to_index: vector to small" severity ERROR;
	return to_integer(unsigned(val(high_c downto val'low)));
    end function;


    function to_addr (
	val, len : natural )
	return std_logic_vector is
    begin
	return std_logic_vector(to_unsigned(val, len));
    end function;

end package body;

----------------------------------------------------------------------------
--  reduce_pkg.vhd
--	Logic Vector Reduction and/or/xor
--	Version 1.0
--
--  SPDX-FileCopyrightText: © 2013 Herbert Poetzl <herbert@13thfloor.at>
--  SPDX-License-Identifier: GPL-2.0-or-later
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;

package reduce_pkg is

    function and_reduce ( val : std_logic_vector )
	return std_logic;

    function or_reduce ( val : std_logic_vector )
	return std_logic;

    function xor_reduce ( val : std_logic_vector )
	return std_logic;

end;

package body reduce_pkg is

    function and_reduce ( val : std_logic_vector )
	return std_logic is

	variable split : natural;

    begin

	if val'length = 0 then
	    return '1';
	elsif val'length = 1 then
	    return val(val'low);
	else
	    split := val'length / 2 + val'low;
	    if val'left < val'right then
		return
		    and_reduce (val(val'low to split - 1)) and
		    and_reduce (val(split to val'high));
	    else
		return
		    and_reduce (val(split - 1 downto val'low)) and
		    and_reduce (val(val'high downto split));
	    end if;
	end if;
    end function;


    function or_reduce ( val : std_logic_vector )
	return std_logic is

	variable split : natural;

    begin

	if val'length = 0 then
	    return '1';
	elsif val'length = 1 then
	    return val(val'low);
	else
	    split := val'length / 2 + val'low;
	    if val'left < val'right then
		return
		    or_reduce (val(val'low to split - 1)) or
		    or_reduce (val(split to val'high));
	    else
		return
		    or_reduce (val(split - 1 downto val'low)) or
		    or_reduce (val(val'high downto split));
	    end if;
	end if;
    end function;


    function xor_reduce ( val : std_logic_vector )
	return std_logic is

	variable split : natural;

    begin

	if val'length = 0 then
	    return '1';
	elsif val'length = 1 then
	    return val(val'low);
	else
	    split := val'length / 2 + val'low;
	    if val'left < val'right then
		return
		    xor_reduce (val(val'low to split - 1)) xor
		    xor_reduce (val(split to val'high));
	    else
		return
		    xor_reduce (val(split - 1 downto val'low)) xor
		    xor_reduce (val(val'high downto split));
	    end if;
	end if;
    end function;

end package body;

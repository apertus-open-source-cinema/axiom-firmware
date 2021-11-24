----------------------------------------------------------------------------
--  fifo_pkg.vhd
--	FIFO related Records, Types and Functions
--	Version 1.0
--
--  SPDX-FileCopyrightText: © 2013 Herbert Poetzl <herbert@13thfloor.at>
--  SPDX-License-Identifier: GPL-2.0-or-later
--
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;

package fifo_pkg is

    function cwidth_f(
	data_width : in natural;
	fifo_size : in string )
	return natural;

end;

package body fifo_pkg is

    function cwidth_f(
	data_width : in natural;
	fifo_size : in string )
	return natural is
	
	variable ret_v : natural;
    begin
	if(fifo_size = "18Kb") then
	    case data_width is
		when 0|1|2|3|4	=> ret_v := 12;
		when 5|6|7|8|9	=> ret_v := 11;
		when 10 to 18	=> ret_v := 10;
		when 19 to 36	=> ret_v := 9;
		when others	=> ret_v := 12;
	    end case;
	elsif(fifo_size = "36Kb") then
	    case data_width is
		when 0|1|2|3|4	=> ret_v := 13;
		when 5|6|7|8|9	=> ret_v := 12;
		when 10 to 18	=> ret_v := 11;
		when 19 to 36	=> ret_v := 10;
		when 37 to 72	=> ret_v := 9;
		when others	=> ret_v := 13;
	    end case;
	end if;
	return ret_v;
    end function;

end package body;

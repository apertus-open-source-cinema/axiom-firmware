----------------------------------------------------------------------------
--  fifo_pkg.vhd
--	FIFO related Records, Types and Functions
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
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

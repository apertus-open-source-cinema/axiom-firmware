------------------------------------------------------------------------
--  ram_sdp_reg.vhd
--  simple dual port RAM with output reg
--
--  Copyright (C) 2013 M.FORET
--
--  This program is free software: you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation, either version
--  2 of the License, or (at your option) any later version.
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;


entity ram_sdp_reg is
    generic (
	DATA_WIDTH : positive :=18;
	ADDR_WIDTH : positive :=12 );
    port (
	-- writing port
	clka   : in  std_logic;
	ena    : in  std_logic;
	wea    : in  std_logic_vector (0 downto 0);
	addra  : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
	dina   : in  std_logic_vector (DATA_WIDTH-1 downto 0);

	-- reading port
	clkb   : in  std_logic;
	enb    : in  std_logic;		-- address/control clock enable
	addrb  : in  std_logic_vector (ADDR_WIDTH-1 downto 0);
	reg_ce : in  std_logic;		-- register clock enable
	doutb  : out std_logic_vector (DATA_WIDTH-1 downto 0)
			:= (others =>'0') );
end entity;


architecture RTL of ram_sdp_reg is

    type mem is array (2 ** ADDR_WIDTH - 1 downto 0) of 
	std_logic_vector (DATA_WIDTH - 1 downto 0);

    signal RAM : mem := (others => ( others => '0'));

    signal d2 : std_logic_vector (DATA_WIDTH-1 downto 0)
	:= (others => '0');

begin

    -- write
    process (clka)
    begin
	if rising_edge(clka) then
	    if ena = '1' then
		if wea(0) = '1' then
		    RAM(to_integer(unsigned(addra))) <= dina;
		end if;
	    end if;
	end if;
    end process;

    -- read
    process (clkb)
    begin
	if rising_edge(clkb) then
	    if enb = '1' then
		d2 <= RAM(to_integer(unsigned(addrb)));
	    end if;
	end if;
    end process;

    process (clkb)
    begin
	if rising_edge(clkb) then
	    if reg_ce = '1' then
		doutb <= d2;
	    end if;
	end if;
    end process;

end RTL;

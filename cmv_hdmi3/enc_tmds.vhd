----------------------------------------------------------------------------
--  enc_tmds.vhd
--	Encode TMDS Data
--	Version 1.0
--
--  Copyright (C) 2014-2015 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes

entity enc_tmds is
    port (
	clk	: in std_logic;
	reset	: in std_logic;
	--
	din	: in std_logic_vector (7 downto 0);
	--
	dout	: out std_logic_vector (9 downto 0)
    );
end entity enc_tmds;

architecture RTL of enc_tmds is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal enc_or : std_logic_vector (8 downto 0);
    signal enc_nor : std_logic_vector (8 downto 0);
    signal word : std_logic_vector (8 downto 0);

    signal set : natural range 0 to 8;
    signal disparity : integer range -4 to 4;
    signal word8 : natural range 0 to 1;

    function bits_set ( val : std_logic_vector )
        return natural is
	variable num : natural := 0;
    begin
	for I in val'range loop
	    if val(I) = '1' then
		num := num + 1;
	    end if;
	end loop;
	return num;
    end function;

begin

    enc_or(0) <= din(0);
    enc_nor(0) <= din(0);

    GEN_ENC: for I in 1 to 7 generate
	enc_or(I) <= din(I) xor enc_or(I - 1);
	enc_nor(I) <= din(I) xnor enc_nor(I - 1);
    end generate;

    enc_or(8) <= '1';
    enc_nor(8) <= '0';

    set <= bits_set(din);

    word <= enc_nor when set > 4
	else enc_nor when set = 4 and din(0) = '0'
	else enc_or;

    disparity <= bits_set(word(7 downto 0)) - 4;
    word8 <= 1 when word(8) = '1' else 0;

    enc_proc: process(clk)

	variable dc_bias : integer range -4 to 4 := 0;

    begin
	if rising_edge(clk) then
	    if reset then
		dc_bias := 0;
	    else	
		if dc_bias = 0 or disparity = 0 then
		    if word8 = 1 then
			dout <= "01" & word(7 downto 0);
			dc_bias := dc_bias + disparity;
		
		    else
			dout <= "10" & not word(7 downto 0);
			dc_bias := dc_bias - disparity;
		
		    end if;

		elsif (dc_bias > 0 and disparity > 0) or
		    (dc_bias < 0 and disparity < 0) then
		    dout <= '1' & word(8) & not word(7 downto 0);
		    dc_bias := dc_bias + word8 - disparity;

		else
		    dout <= '0' & word;
		    dc_bias := dc_bias + 1 - word8 + disparity;

		end if;
	    end if;
	end if;
    end process;

end RTL;

architecture FIELD of enc_tmds is

    signal xored  : STD_LOGIC_VECTOR (8 downto 0);
    signal xnored : STD_LOGIC_VECTOR (8 downto 0);
    
    signal ones                : STD_LOGIC_VECTOR (3 downto 0);
    signal data_word           : STD_LOGIC_VECTOR (8 downto 0);
    signal data_word_inv       : STD_LOGIC_VECTOR (8 downto 0);
    signal data_word_disparity : STD_LOGIC_VECTOR (3 downto 0);
    signal dc_bias             : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');

begin

    -- Work our the two different encodings for the byte
    xored(0) <= din(0);
    xored(1) <= din(1) xor xored(0);
    xored(2) <= din(2) xor xored(1);
    xored(3) <= din(3) xor xored(2);
    xored(4) <= din(4) xor xored(3);
    xored(5) <= din(5) xor xored(4);
    xored(6) <= din(6) xor xored(5);
    xored(7) <= din(7) xor xored(6);
    xored(8) <= '1';
    
    xnored(0) <= din(0);
    xnored(1) <= din(1) xnor xnored(0);
    xnored(2) <= din(2) xnor xnored(1);
    xnored(3) <= din(3) xnor xnored(2);
    xnored(4) <= din(4) xnor xnored(3);
    xnored(5) <= din(5) xnor xnored(4);
    xnored(6) <= din(6) xnor xnored(5);
    xnored(7) <= din(7) xnor xnored(6);
    xnored(8) <= '0';
    
    -- Count how many ones are set in data
    ones <= "0000" + din(0) + din(1) + din(2) + din(3)
                    + din(4) + din(5) + din(6) + din(7);

    -- Decide which encoding to use
    process(ones, din(0), xnored, xored)
    begin
       if ones > 4 or (ones = 4 and din(0) = '0') then
	  data_word     <= xnored;
	  data_word_inv <= NOT(xnored);
       else
	  data_word     <= xored;
	  data_word_inv <= NOT(xored);
       end if;
    end process;                                          

    -- Work out the DC bias of the dataword;
    data_word_disparity  <= "1100" + 
	data_word(0) + data_word(1) + data_word(2) + data_word(3) + 
	data_word(4) + data_word(5) + data_word(6) + data_word(7);

    -- Now work out what the output should be
    process(clk)
    begin
       if rising_edge(clk) then
          if reset then
             dc_bias <= (others => '0');
          else
             if dc_bias = "00000" or data_word_disparity = 0 then
                -- dataword has no disparity
                if data_word(8) = '1' then
                   dout <= "01" & data_word(7 downto 0);
                   dc_bias <= dc_bias + data_word_disparity;
                else
                   dout <= "10" & data_word_inv(7 downto 0);
                   dc_bias <= dc_bias - data_word_disparity;
                end if;
             elsif (dc_bias(3) = '0' and data_word_disparity(3) = '0') or 
                   (dc_bias(3) = '1' and data_word_disparity(3) = '1') then
                dout <= '1' & data_word(8) & data_word_inv(7 downto 0);
                dc_bias <= dc_bias + data_word(8) - data_word_disparity;
             else
                dout <= '0' & data_word;
                dc_bias <= dc_bias - data_word_inv(8) + data_word_disparity;
             end if;
          end if;
       end if;
    end process;      
end FIELD;

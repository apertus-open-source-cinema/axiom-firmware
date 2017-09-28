----------------------------------------------------------------------------
--  fifo_chop.vhd
--	FIFO Data Serializer
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
--------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;

library unimacro;
use unimacro.VCOMPONENTS.ALL;

use work.vivado_pkg.ALL;	-- Vivado Attributes
use work.fifo_pkg.ALL;		-- FIFO Functions
use work.par_array_pkg.ALL;	-- Parallel Data


entity fifo_chop is
    port (
	par_clk		: in  std_logic;
	par_enable	: in  std_logic;
	par_data	: in  par12_a (31 downto 0);
	--
	par_ctrl	: in  std_logic_vector (11 downto 0);
	--
	fifo_clk	: out std_logic;
	fifo_enable	: out std_logic;
	fifo_data	: out std_logic_vector (63 downto 0);
	--
	fifo_ctrl	: out std_logic_vector (11 downto 0)
    );

end entity fifo_chop;


architecture RTL of fifo_chop is

    attribute KEEP_HIERARCHY of RTL : architecture is "TRUE";

    signal data_sel : std_logic_vector (16 * 12 - 1 downto 0);
    signal ctrl_sel : std_logic_vector (11 downto 0);
    signal sel : unsigned(3 downto 0) := (others => '1');

begin

    sel_proc : process (par_clk)
	variable data_v : std_logic_vector (32 * 12 - 1 downto 0);
	variable ctrl_v : std_logic_vector (11 downto 0);
	variable sel_v : unsigned(3 downto 0) := (others => '0');
    begin
	if rising_edge(par_clk) then
	    if par_enable = '1' then
		for I in 31 downto 0 loop
		    data_v(I*12 + 11 downto I*12) := par_data(I);
		end loop;
		sel_v := (others => '0');
		ctrl_v := par_ctrl;
	    else
		if sel_v(2) = '0' then
		    data_sel <= data_v(16 * 12 - 1 downto 0);
		else
		    data_sel <= data_v(32 * 12 - 1 downto 16 * 12);
		end if;
		ctrl_sel <= ctrl_v;
		sel <= sel_v;

		if sel_v(3) = '0' then
		    sel_v := sel_v + "1";
		end if;
	    end if;
	end if;
    end process;

    fifo_proc : process (par_clk)
    begin
	if rising_edge(par_clk) then
	    case sel(1 downto 0) is
		when "11" =>
		    fifo_data(47 downto 0) <=
			data_sel(16 * 12 - 1 downto 12 * 12);

		when "10" =>
		    fifo_data(47 downto 0) <=
			data_sel(12 * 12 - 1 downto 8 * 12);

		when "01" =>
		    fifo_data(47 downto 0) <=
			data_sel(8 * 12 - 1 downto 4 * 12);

		when others =>
		    fifo_data(47 downto 0) <=
			data_sel(4 * 12 - 1 downto 0);
	    end case;
	    fifo_enable <= not sel(3);
	    fifo_ctrl <= ctrl_sel;
	end if;
    end process;

    fifo_clk <= par_clk;

end RTL;


architecture RTL_SHIFT of fifo_chop is

    attribute KEEP_HIERARCHY of RTL_SHIFT : architecture is "TRUE";

begin

    fifo_proc : process (par_clk)
	variable shift_v : std_logic_vector (32 * 12 - 1 downto 0);
	variable shift_cnt_v : std_logic_vector (8 downto 0)
	    := (0 => '0', others => '1');
	variable ctrl_v : std_logic_vector (11 downto 0);
	variable enable_v : std_logic := '0';
	variable bcnt_v : unsigned(3 downto 0);
    begin
	if rising_edge(par_clk) then
	    if par_enable = '1' and enable_v = '0' then
		for I in 31 downto 0 loop
		    shift_v(I*12 + 11 downto I*12) := par_data(I);
		    -- shift_v(I*12 + 11 downto I*12 + 4) :=
			-- std_logic_vector(to_unsigned(I, 8));
		end loop;
		shift_cnt_v := (0 => '0', others => '1');
		ctrl_v := par_ctrl;
		bcnt_v := (others => '0');
	    else
		for I in 0 to 6 loop
		    if shift_cnt_v(0) = '1' then
			shift_v(I * 48 + 47 downto I * 48) :=
			    shift_v((I + 1) * 48 + 47 downto (I + 1) * 48);
		    end if;
		end loop;
		shift_cnt_v := '0' &
		    shift_cnt_v(shift_cnt_v'high downto 1);
		bcnt_v := bcnt_v + "1";
	    end if;

	    enable_v := par_enable;
	end if;

	fifo_data(63 downto 16) <= shift_v(47 downto 0);
	fifo_data(15 downto 0) <= std_logic_vector(bcnt_v) & ctrl_v;
	fifo_enable <= shift_cnt_v(0);
	fifo_ctrl <= ctrl_v;
    end process;

    fifo_clk <= par_clk;

end RTL_SHIFT;


architecture RTL_PACKED of fifo_chop is

    attribute KEEP_HIERARCHY of RTL_PACKED : architecture is "TRUE";

begin

    fifo_proc : process (par_clk)
	variable shift_v : std_logic_vector (32 * 12 - 1 downto 0);
	variable shift_cnt_v : std_logic_vector (6 downto 0)
	    := (0 => '0', others => '1');
	variable ctrl_v : std_logic_vector (11 downto 0);
	variable enable_v : std_logic := '0';
    begin
	if rising_edge(par_clk) then
	    if par_enable = '1' and enable_v = '0' then
		for I in 31 downto 0 loop
		    shift_v(I*12 + 11 downto I*12) := par_data(I);
		    -- shift_v(I*12 + 11 downto I*12 + 4) :=
			-- std_logic_vector(to_unsigned(I, 8));
		end loop;
		shift_cnt_v := (0 => '0', others => '1');
		ctrl_v := par_ctrl;
	    else
		for I in 0 to 4 loop
		    if shift_cnt_v(0) = '1' then
			shift_v(I * 64 + 63 downto I * 64) :=
			    shift_v((I + 1) * 64 + 63 downto (I + 1) * 64);
		    end if;
		end loop;
		shift_cnt_v := '0' &
		    shift_cnt_v(shift_cnt_v'high downto 1);
	    end if;

	    enable_v := par_enable;
	end if;

	fifo_data <= shift_v(63 downto 0);
	fifo_enable <= shift_cnt_v(0);
	fifo_ctrl <= ctrl_v;
    end process;

    fifo_clk <= par_clk;

end RTL_PACKED;

----------------------------------------------------------------------------
--  serdes_wrap.vhd
--	Wrapper for SERDESE2
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
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;


entity oserdes_wrap is
    generic (
        DATA_RATE_OQ	: string		:= "SDR";
        DATA_RATE_TQ	: string		:= "SDR";
        DATA_WIDTH	: integer		:= 2;
        INIT_OQ 	: bit			:= '0';
        INIT_TQ 	: bit			:= '0';
        SERDES_MODE	: string		:= "MASTER";
        SRVAL_OQ	: bit			:= '0';
        SRVAL_TQ	: bit			:= '0';
        TBYTE_CTL	: string		:= "FALSE";
        TBYTE_SRC	: string		:= "FALSE";
        TRISTATE_WIDTH	: integer		:= 1
    );
    port (
        CLK		: in std_logic;
        CLKDIV		: in std_logic;
	--
        OCE		: in std_logic		:= '1';
        RST		: in std_logic		:= '0';
	--
        D1		: in std_logic		:= '0';
        D2		: in std_logic		:= '0';
        D3		: in std_logic		:= '0';
        D4		: in std_logic		:= '0';
        D5		: in std_logic		:= '0';
        D6		: in std_logic		:= '0';
        D7		: in std_logic		:= '0';
        D8		: in std_logic		:= '0';
	--
        OFB		: out std_logic;
        OQ		: out std_logic;
	--
        SHIFTIN1	: in std_logic		:= '0';
        SHIFTIN2	: in std_logic		:= '0';
	--
        SHIFTOUT1	: out std_logic;
        SHIFTOUT2	: out std_logic;
	--
        TCE		: in std_logic		:= '0';
	--
        T1		: in std_logic		:= '0';
        T2		: in std_logic		:= '0';
        T3		: in std_logic		:= '0';
        T4		: in std_logic		:= '0';
	--
        TFB		: out std_logic;
        TQ		: out std_logic;
	--
        TBYTEIN 	: in std_logic		:= '0';
        TBYTEOUT	: out std_logic
    );
end entity oserdes_wrap;


architecture RTL of oserdes_wrap is
begin

    OSERDESE2_inst : OSERDESE2
	generic map (
	    DATA_RATE_OQ => DATA_RATE_OQ,	-- DDR, SDR
	    DATA_RATE_TQ => DATA_RATE_TQ,	-- DDR, BUF, SDR
	    DATA_WIDTH => DATA_WIDTH,		-- Parallel data width (2-8,10,14)
	    INIT_OQ => INIT_OQ,			-- Initial value of OQ output (1'b0,1'b1)
	    INIT_TQ => INIT_TQ,			-- Initial value of TQ output (1'b0,1'b1)
	    SERDES_MODE => SERDES_MODE,		-- MASTER, SLAVE
	    SRVAL_OQ => SRVAL_OQ,		-- OQ output value when SR is used (1'b0,1'b1)
	    SRVAL_TQ => SRVAL_TQ,		-- TQ output value when SR is used (1'b0,1'b1)
	    TBYTE_CTL => TBYTE_CTL,		-- Enable tristate byte operation (FALSE, TRUE)
	    TBYTE_SRC => TBYTE_SRC,		-- Tristate byte source (FALSE, TRUE)
	    TRISTATE_WIDTH => TRISTATE_WIDTH )	-- 3-state converter width (1,4)
	port map (
	    CLK => CLK,				-- 1-bit input: High speed clock
	    CLKDIV => CLKDIV,			-- 1-bit input: Divided clock
	    --
	    OCE => OCE,				-- 1-bit input: Output data clock enable
	    RST => RST,				-- 1-bit input: Reset
	    --
	    D1 => D1,
	    D2 => D2,
	    D3 => D3,
	    D4 => D4,
	    D5 => D5,
	    D6 => D6,
	    D7 => D7,
	    D8 => D8,
	    --
	    OFB => OFB,				-- 1-bit output: Feedback path for data
	    OQ => OQ,				-- 1-bit output: Data path output
	    --
	    SHIFTIN1 => SHIFTIN1,
	    SHIFTIN2 => SHIFTIN2,
	    --
	    SHIFTOUT1 => SHIFTOUT1,
	    SHIFTOUT2 => SHIFTOUT2,
	    --
	    TCE => TCE,				-- 1-bit input: 3-state clock enable
	    --
	    T1 => T1,
	    T2 => T2,
	    T3 => T3,
	    T4 => T4,
	    --
	    TFB => TFB,				-- 1-bit output: 3-state control
	    TQ => TQ,				-- 1-bit output: 3-state control
	    --
	    TBYTEIN => TBYTEIN,			-- 1-bit input: Byte group tristate
	    TBYTEOUT => TBYTEOUT );		-- 1-bit output: Byte group tristate

end RTL;


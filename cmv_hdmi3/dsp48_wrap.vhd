----------------------------------------------------------------------------
--  dsp48_wrap.vhd
--	Wrapper for DSP48E1
--	Version 1.1
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
use IEEE.numeric_std.ALL;

library unisim;
use unisim.VCOMPONENTS.ALL;


entity dsp48_wrap is
    generic (
	AREG			: integer			:= 0;
	BREG			: integer			:= 0;
	CREG			: integer			:= 0;
	DREG			: integer			:= 0;
	MREG			: integer			:= 0;
	PREG			: integer			:= 0;
	ADREG			: integer			:= 0;
	ACASCREG		: integer			:= 0;
	BCASCREG		: integer			:= 0;
	INMODEREG		: integer			:= 0;
	OPMODEREG		: integer			:= 0;
	ALUMODEREG		: integer			:= 0;
	CARRYINREG		: integer			:= 0;
	CARRYINSELREG		: integer			:= 0;
	--
	A_INPUT			: string			:= "DIRECT";
	B_INPUT			: string			:= "DIRECT";
	--
	MASK			: bit_vector			:= X"FFFFFFFFFFFF";
	PATTERN			: bit_vector			:= X"000000000000";
	SEL_MASK		: string			:= "MASK";
	SEL_PATTERN		: string			:= "PATTERN";
	AUTORESET_PATDET	: string			:= "NO_RESET";
	--
	USE_DPORT		: boolean			:= FALSE;
	USE_MULT		: string			:= "NONE";
	USE_PATTERN_DETECT	: string			:= "NO_PATDET";
	USE_SIMD		: string			:= "ONE48";
	--
	IS_CLK_INVERTED		: bit				:= '0';
	IS_INMODE_INVERTED	: std_logic_vector (4 downto 0) := "00000";
	IS_OPMODE_INVERTED	: std_logic_vector (6 downto 0) := "0000000";
	IS_ALUMODE_INVERTED	: std_logic_vector (3 downto 0) := "0000";
	IS_CARRYIN_INVERTED	: bit				:= '0'
    );
    port (
	CLK		: in std_logic;
	--
	A		: in std_logic_vector (29 downto 0)	:= (others => '0');
	B		: in std_logic_vector (17 downto 0)	:= (others => '0');
	C		: in std_logic_vector (47 downto 0)	:= (others => '0');
	D		: in std_logic_vector (24 downto 0)	:= (others => '0');
	--
	INMODE		: in std_logic_vector (4 downto 0)	:= (others => '0');
	OPMODE		: in std_logic_vector (6 downto 0)	:= (others => '0');
	ALUMODE		: in std_logic_vector (3 downto 0)	:= (others => '0');
	CARRYINSEL	: in std_logic_vector (2 downto 0)	:= (others => '0');
	CARRYIN		: in std_logic				:= '0';
	--
	CEA1		: in std_logic				:= '0';
	CEA2		: in std_logic				:= '0';
	CEB1		: in std_logic				:= '0';
	CEB2		: in std_logic				:= '0';
	CEC		: in std_logic				:= '0';
	CED		: in std_logic				:= '0';
	CEM		: in std_logic				:= '0';
	CEP		: in std_logic				:= '0';
	CEAD		: in std_logic				:= '0';
	--
	CEINMODE	: in std_logic				:= '0';
	CEALUMODE	: in std_logic				:= '0';
	CECTRL		: in std_logic				:= '0';
	CECARRYIN	: in std_logic				:= '0';
	--
	RSTA		: in std_logic				:= '0';
	RSTB		: in std_logic				:= '0';
	RSTC		: in std_logic				:= '0';
	RSTD		: in std_logic				:= '0';
	RSTM		: in std_logic				:= '0';
	RSTP		: in std_logic				:= '0';
	--
	RSTINMODE	: in std_logic				:= '0';
	RSTALUMODE	: in std_logic				:= '0';
	RSTCTRL		: in std_logic				:= '0';
	RSTALLCARRYIN	: in std_logic				:= '0';
	--
	ACIN		: in std_logic_vector (29 downto 0)	:= (others => '0');
	BCIN		: in std_logic_vector (17 downto 0)	:= (others => '0');
	PCIN		: in std_logic_vector (47 downto 0)	:= (others => '0');
	MULTSIGNIN	: in std_logic				:= '0';
	CARRYCASCIN	: in std_logic				:= '0';
	--
	P		: out std_logic_vector (47 downto 0);
	--
	ACOUT		: out std_logic_vector (29 downto 0);
	BCOUT		: out std_logic_vector (17 downto 0);
	PCOUT		: out std_logic_vector (47 downto 0);
	CARRYOUT	: out std_logic_vector (3 downto 0);
	CARRYCASCOUT	: out std_logic;
	MULTSIGNOUT	: out std_logic;
	--
	PATTERNDETECT	: out std_logic;
	PATTERNBDETECT	: out std_logic;
	--
	OVERFLOW	: out std_logic;
	UNDERFLOW	: out std_logic
    );
end entity dsp48_wrap;


architecture RTL of dsp48_wrap is
begin

    DSP48E1_inst : DSP48E1
	generic map (
	    AREG => AREG,			-- Pipeline stages for A (0, 1 or 2)
	    BREG => BREG,			-- Pipeline stages for B (0, 1 or 2)
	    CREG => CREG,			-- Pipeline stages for C (0 or 1)
	    DREG => DREG,			-- Pipeline stages for D (0 or 1)
	    MREG => MREG,			-- Pipeline stages for M (0 or 1)
	    PREG => PREG,			-- Pipeline stages for P (0 or 1)
	    ADREG => ADREG,			-- Pipeline stages for pre-adder (0 or 1)
	    ACASCREG => ACASCREG,		-- Pipeline stages A/ACIN to ACOUT (0, 1 or 2)
	    BCASCREG => BCASCREG,		-- Pipeline stages B/BCIN to BCOUT (0, 1 or 2)
	    INMODEREG => INMODEREG,		-- Pipeline stages for INMODE (0 or 1)
	    OPMODEREG => OPMODEREG,		-- Pipeline stages for OPMODE (0 or 1)
	    ALUMODEREG => ALUMODEREG,		-- Pipeline stages for ALUMODE (0 or 1)
	    CARRYINREG => CARRYINREG,		-- Pipeline stages for CARRYIN (0 or 1)
	    CARRYINSELREG => CARRYINSELREG,	-- Pipeline stages for CARRYINSEL (0 or 1)
	    --
	    A_INPUT => A_INPUT,			-- Input to A port ("DIRECT", "CASCADE")
	    B_INPUT => B_INPUT,			-- Input to B port ("DIRECT", "CASCADE")
	    --
	    MASK => MASK,			-- 48-bit mask value for pattern detect (1=ignore)
	    PATTERN => PATTERN,			-- 48-bit pattern match for pattern detect
	    SEL_MASK => SEL_MASK,		-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
	    SEL_PATTERN => SEL_PATTERN,		-- Select pattern value ("PATTERN" or "C")
	    AUTORESET_PATDET => AUTORESET_PATDET, -- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
	    --
	    USE_DPORT => USE_DPORT,		-- Activate preadder (FALSE, TRUE)
	    USE_MULT => USE_MULT,		-- "NONE", "MULTIPLY", "DYNAMIC"
	    USE_PATTERN_DETECT => USE_PATTERN_DETECT, -- ("PATDET" or "NO_PATDET")
	    USE_SIMD => USE_SIMD,		-- SIMD selection ("ONE48", "TWO24", "FOUR12")
	    --
	    IS_CLK_INVERTED => IS_CLK_INVERTED,
	    IS_INMODE_INVERTED => IS_INMODE_INVERTED,
	    IS_OPMODE_INVERTED => IS_OPMODE_INVERTED,
	    IS_ALUMODE_INVERTED => IS_ALUMODE_INVERTED,
	    IS_CARRYIN_INVERTED => IS_CARRYIN_INVERTED )
	port map (
	    CLK => CLK,				-- 1-bit input: Clock input
	    --
	    A => A,				-- 30-bit input: A data input
	    B => B,				-- 18-bit input: B data input
	    C => C,				-- 48-bit input: C data input
	    D => D,				-- 25-bit input: D data input
	    --
	    INMODE => INMODE,			-- 5-bit input: INMODE control input
	    OPMODE => OPMODE,			-- 7-bit input: Operation mode input
	    ALUMODE => ALUMODE,			-- 4-bit input: ALU control input
	    CARRYINSEL => CARRYINSEL,		-- 3-bit input: Carry select input
	    CARRYIN => CARRYIN,			-- 1-bit input: Carry input signal
	    --
	    CEA1 => CEA1,			-- 1-bit input: CE input for 1st stage AREG
	    CEA2 => CEA2,			-- 1-bit input: CE input for 2nd stage AREG
	    CEB1 => CEB1,			-- 1-bit input: CE input for 1st stage BREG
	    CEB2 => CEB2,			-- 1-bit input: CE input for 2nd stage BREG
	    CEC => CEC,				-- 1-bit input: CE input for CREG
	    CED => CED,				-- 1-bit input: CE input for DREG
	    CEM => CEM,				-- 1-bit input: CE input for MREG
	    CEP => CEP,				-- 1-bit input: CE input for PREG
	    CEAD => CEAD,			-- 1-bit input: CE input for ADREG
	    --
	    CEINMODE => CEINMODE,		-- 1-bit input: CE input for INMODREG
	    CEALUMODE => CEALUMODE,		-- 1-bit input: CE input for ALUMODERE
	    CECTRL => CECTRL,			-- 1-bit input: CE input for OPMODEREG and CARRYINSELREG
	    CECARRYIN => CECARRYIN,		-- 1-bit input: CE input for CARRYINREG
	    --
	    RSTA => RSTA,			-- 1-bit input: Reset input for AREG
	    RSTB => RSTB,			-- 1-bit input: Reset input for BREG
	    RSTC => RSTC,			-- 1-bit input: Reset input for CREG
	    RSTD => RSTD,			-- 1-bit input: Reset input for DREG and ADREG
	    RSTM => RSTM,			-- 1-bit input: Reset input for MREG
	    RSTP => RSTP,			-- 1-bit input: Reset input for PREG
	    --
	    RSTINMODE => RSTINMODE,		-- 1-bit input: Reset input for INMODREG
	    RSTALUMODE => RSTALUMODE,		-- 1-bit input: Reset input for ALUMODEREG
	    RSTCTRL => RSTCTRL,			-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
	    RSTALLCARRYIN => RSTALLCARRYIN,	-- 1-bit input: Reset input for CARRYINREG
	    --
	    ACIN => ACIN,			-- 30-bit input: A cascade data input
	    BCIN => BCIN,			-- 18-bit input: B cascade data input
	    PCIN => PCIN,			-- 48-bit input: P cascade input
	    MULTSIGNIN => MULTSIGNIN,		-- 1-bit input: Multiplier sign input
	    CARRYCASCIN => CARRYCASCIN,		-- 1-bit input: Cascade carry input
	    --
	    P => P,				-- 48-bit output: Primary data output
	    --
	    ACOUT => ACOUT,			-- Cascaded data output to ACIN of next slice
	    BCOUT => BCOUT,			-- Cascaded data output to BCIN of next slice
	    PCOUT => PCOUT,			-- Cascaded data output to PCIN of next slice
	    CARRYOUT => CARRYOUT,		-- 4-bit carry output
	    CARRYCASCOUT => CARRYCASCOUT,	-- Cascaded carry output to CARRYCASCIN of next slice
	    MULTSIGNOUT => MULTSIGNOUT,		-- Sign of the multiplied result cascaded to the next slice
	    --
	    PATTERNDETECT => PATTERNDETECT,	-- Match indicator between P[47:0] and the pattern bar
	    PATTERNBDETECT => PATTERNBDETECT,	-- Match indicator between P[47:0] and the pattern
	    --
	    OVERFLOW => OVERFLOW,		-- Overflow indicator
	    UNDERFLOW => UNDERFLOW );		-- Undeflow indicator

end RTL;

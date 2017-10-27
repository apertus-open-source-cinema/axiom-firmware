/**********************************************************************
**  scn_reg.h
**	Register Definitions
**	Version 1.1
**
**  Copyright (C) 2013-2014 H.Poetzl
**
**	This program is free software: you can redistribute it and/or
**	modify it under the terms of the GNU General Public License
**	as published by the Free Software Foundation, either version
**	2 of the License, or (at your option) any later version.
**
**********************************************************************/

#ifndef	_SCN_REG_H_
#define	_SCN_REG_H_


uint32_t scn_addr = 0x00000000;

uint32_t get_scn_reg(unsigned reg)
{
	volatile uint32_t *ptr = (uint32_t *)(scn_addr + 0x00000100);
	return ptr[reg];
}

void	set_scn_reg(unsigned reg, uint32_t val)
{
	volatile uint32_t *ptr = (uint32_t *)(scn_addr + 0x00000100);
	ptr[reg] = val;
	usleep(10);
}

enum _scn_reg {
	SCN_REG_TOTAL = 0,
	SCN_REG_TOTALF = 1,

	SCN_REG_HDISP = 2,
	SCN_REG_VDISP = 3,
	SCN_REG_HSYNC = 4,
	SCN_REG_VSYNC = 5,
	SCN_REG_HDATA = 6,
	SCN_REG_VDATA = 7,

	SCN_REG_EVENT01 = 8,
	SCN_REG_EVENT23 = 9,
	SCN_REG_EVENT45 = 10,
	SCN_REG_EVENT67 = 11,

	SCN_REG_STATUS = 65,
};

uint32_t get_gen_reg(unsigned reg)
{
	volatile uint32_t *ptr = (uint32_t *)(scn_addr + 0x00100100);
	return ptr[reg];
}

void	set_gen_reg(unsigned reg, uint32_t val)
{
	volatile uint32_t *ptr = (uint32_t *)(scn_addr + 0x00100100);
	ptr[reg] = val;
	usleep(10);
}

enum _gen_reg {
	GEN_REG_BUF0 = 0,
	GEN_REG_PAT0 = 1,
	GEN_REG_BUF1 = 2,
	GEN_REG_PAT1 = 3,
	GEN_REG_BUF2 = 4,
	GEN_REG_PAT2 = 5,
	GEN_REG_BUF3 = 6,
	GEN_REG_PAT3 = 7,

	GEN_REG_CINC = 8,
	GEN_REG_RINC = 9,
	GEN_REG_CCNT = 10,

	GEN_REG_CONTROL = 11,

	GEN_REG_CODE0 = 12,
	GEN_REG_CODE1 = 13,
	GEN_REG_CODE2 = 14,
	GEN_REG_CODE3 = 15,

	GEN_REG_ADDR = 65,
	GEN_REG_STATUS = 66,
};

#endif	/* _SCN_REG_H_ */

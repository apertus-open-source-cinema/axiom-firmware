/**********************************************************************
**  cmv_reg.h
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

#ifndef	_CMV_REG_H_
#define	_CMV_REG_H_

#ifdef	REG_DELAY
#define	delay(n)	usleep(REG_DELAY * n)
#else
#define	delay(n)	do { } while (0)
#endif

uint32_t cmv_addr = 0x00000000;

uint16_t get_cmv_reg(unsigned reg)
{
	volatile uint32_t *ptr = (uint32_t *)(cmv_addr + 0x00000000);
	return ptr[reg] & 0xFFFF;
}

void	set_cmv_reg(unsigned reg, uint16_t val)
{
	volatile uint32_t *ptr = (uint32_t *)(cmv_addr + 0x00000000);
	ptr[reg] = val;
	delay(1);
}



uint32_t get_fil_reg(unsigned reg)
{
	volatile uint32_t *ptr = (uint32_t *)(cmv_addr + 0x00100100);
	return ptr[reg];
}

void	set_fil_reg(unsigned reg, uint32_t val)
{
	volatile uint32_t *ptr = (uint32_t *)(cmv_addr + 0x00100100);
	ptr[reg] = val;
	delay(1);
}

enum _fil_reg {
	FIL_REG_BUF0 = 0,
	FIL_REG_PAT0 = 1,
	FIL_REG_BUF1 = 2,
	FIL_REG_PAT1 = 3,
	FIL_REG_BUF2 = 4,
	FIL_REG_PAT2 = 5,
	FIL_REG_BUF3 = 6,
	FIL_REG_PAT3 = 7,

	FIL_REG_CINC = 8,
	FIL_REG_RINC = 9,
	FIL_REG_CCNT = 10,

	FIL_REG_CONTROL = 11,

	FIL_REG_PATTERN = 12,
	FIL_REG_MASKVAL = 13,

	FIL_REG_LEDOVR = 14,
	FIL_REG_OVERRIDE = 15,

	FIL_REG_USR_ACCESS = 65,
	FIL_REG_MATCH = 66,
	FIL_REG_MISMATCH = 67,
	FIL_REG_ADDR = 68,
	FIL_REG_STATUS = 69,
	FIL_REG_CSEQ = 70,
};




uint32_t get_del_reg(unsigned reg)
{
	volatile uint32_t *ptr = (uint32_t *)(cmv_addr + 0x00200000);
	return ptr[reg];
}

void	set_del_reg(unsigned reg, uint32_t val)
{
	volatile uint32_t *ptr = (uint32_t *)(cmv_addr + 0x00200000);
	ptr[reg] = val;
	delay(5);
}


uint32_t get_rcn_col(unsigned col)
{
	volatile uint32_t *ptr = (uint32_t *)(cmv_addr + 0x00302000);
	return ptr[(col/2) - (col&1)*0x800];
}

void	set_rcn_col(unsigned col, uint32_t val)
{
	volatile uint32_t *ptr = (uint32_t *)(cmv_addr + 0x00302000);
	ptr[(col/2) - (col&1)*0x800] = val;
}

uint32_t get_rcn_row(unsigned row)
{
	volatile uint32_t *ptr = (uint32_t *)(cmv_addr + 0x00304000);
	return ptr[(row/2) + (row&1)*0x800];
}

void	set_rcn_row(unsigned row, uint32_t val)
{
	volatile uint32_t *ptr = (uint32_t *)(cmv_addr + 0x00304000);
	ptr[(row/2) + (row&1)*0x800] = val;
}


#endif	/* _CMV_REG_H_ */

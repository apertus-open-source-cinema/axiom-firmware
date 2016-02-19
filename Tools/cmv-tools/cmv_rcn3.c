/**********************************************************************
**  cmv_rcn3.c
**	Row Col Noise Correction
**	Version 1.1
**
**  Copyright (C) 2014 H.Poetzl
**
**	This program is free software: you can redistribute it and/or
**	modify it under the terms of the GNU General Public License
**	as published by the Free Software Foundation, either version
**	2 of the License, or (at your option) any later version.
**
**********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>

#include "cmv_reg.h"

#define	VERSION	"V1.1"

static char *cmd_name = NULL;

static uint32_t cmv_base = 0x60000000;
static uint32_t cmv_size = 0x00400000;

static uint32_t map_base = 0x18000000;
static uint32_t map_size = 0x08000000;

static uint32_t map_addr = 0x00000000;

static uint32_t buf_base[4] = { -1, -1, -1, -1 };
static uint32_t buf_epat[4] = { -1, -1, -1, -1 };

static char *dev_mem = "/dev/mem";

static uint16_t num_cols = 4096;
static uint16_t num_rows = 3072;

static uint16_t num_samples = 1;

static bool opt_snap = false;

static bool opt_zero = false;
static bool opt_avg = false;
static bool opt_cols = false;
static bool opt_rows = false;


typedef long long int (stoll_t)(const char *, char **, int);

long long int argtoll(
	const char *str, const char **end, stoll_t stoll)
{
	int bit, inv = 0;
	long long int val = 0;
	char *eptr;

	if (!str)
	    return -1;
	if (!stoll)
	    stoll = strtoll;
	
	switch (*str) {
	case '~':
	case '!':
	    inv = 1;	/* invert */
	    str++;
	default:
	    break;
	}

	while (*str) {
	    switch (*str) {
	    case '^':
		bit = strtol(str+1, &eptr, 0);
		val ^= (1LL << bit);
		break;
	    case '&':
		val &= stoll(str+1, &eptr, 0);
		break;
	    case '|':
		val |= stoll(str+1, &eptr, 0);
		break;
	    case '-':
	    case '+':
	    case ',':
	    case '=':
		break;
	    default:
		val = stoll(str, &eptr, 0);
		break;
	    }
	    if (eptr == str)
		break;
	    str = eptr;
	}

	if (end)
	    *end = eptr;
	return (inv)?~(val):(val);
}


static inline
uint16_t col_row(uint64_t *buf, uint16_t col, uint16_t row)
{
	static int shift[2][2] = { { 52, 40 } , { 28, 16 } };

	uint32_t off = (col/2) + (row/2)*2048;
	uint64_t val = buf[off];
	// fprintf(stderr, "val=%016llX\n", (unsigned long long)val);
	return (val >> shift[row & 1][col & 1]) & 0xFFF;
}


static inline
uint16_t calc_avg_col(uint64_t *buf, uint16_t col)
{
	uint64_t sum = 0;

	for (int r=0; r<3072; r++)
	    sum += col_row(buf, col, r);

	return sum*16/3072;
}

void	calc_avg_cols(uint64_t *buf, uint32_t *avg)
{
	for (int c=0; c<num_cols; c++)
	    avg[c] += calc_avg_col(buf, c);
}


static inline
uint16_t calc_avg_row(uint64_t *buf, uint16_t row)
{
	uint64_t sum = 0;

	for (int c=0; c<num_cols; c++)
	    sum += col_row(buf, c, row);

	return sum*16/num_cols;
}

void	calc_avg_rows(uint64_t *buf, uint32_t *avg)
{
	for (int r=0; r<3072; r++)
	    avg[r] += calc_avg_row(buf, r);
}


void	calc_min_max(uint32_t *val, uint16_t *mm, uint16_t num, uint16_t div)
{
	uint16_t min_val[2] = { ~0, ~0 };
	uint16_t max_val[2] = { 0, 0 };
	uint64_t sum[2] = { 0, 0 };

	for (int i=0; i<2; i++) {
	    for (int n=i; n<num; n+=2) {
		uint16_t rval = val[n]/div;
		if (min_val[i] > rval)
		    min_val[i] = rval;
		if (max_val[i] < rval)
		    max_val[i] = rval;
		sum[i] += rval;
	    }
	    mm[i+0] = min_val[i];
	    mm[i+2] = max_val[i];
	    mm[i+4] = sum[i]*2/num;
	}
}

void	apply_colc(uint32_t *val, uint16_t *off, uint16_t div)
{
	for (int c=0; c<num_cols; c++)
	    set_rcn_col(c, (off[c & 1] - val[c]/div));
}

void	apply_rowc(uint32_t *val, uint16_t *off, uint16_t div)
{
	for (int r=0; r<num_rows; r++)
	    set_rcn_row(r, (off[r & 1] - val[r]/div));
}


#define	OPTIONS	"hacrszN:B:S:"

int	main(int argc, char *argv[])
{
	extern int optind;
	extern char *optarg;
	int c, err_flag = 0;

	cmd_name = argv[0];
	while ((c = getopt(argc, argv, OPTIONS)) != EOF) {
	    switch (c) {
	    case 'h':
		fprintf(stderr,
		    "This is %s " VERSION "\n"
		    "options are:\n"
		    "-h        print this help message\n"
		    "-a        calculate average\n"
		    "-c        adjust columns\n"
		    "-r        adjust rows\n"
		    "-s        acquire snapshot\n"
		    "-z        zero noise correction\n"
		    "-N <cnt>  average over samples\n"
		    "-B <val>  register mapping base\n"
		    "-S <val>  register mapping size\n"
		    , cmd_name);
		exit(0);
		break;
	    case 'a':
		opt_avg = true;
		break;
	    case 'c':
		opt_cols = true;
		break;
	    case 'r':
		opt_rows = true;
		break;
	    case 's':
		opt_snap = true;
		break;
	    case 'z':
		opt_zero = true;
		break;
	    case 'N':
		num_samples = argtoll(optarg, NULL, NULL);
		break;
	    case 'B':
		cmv_base = argtoll(optarg, NULL, NULL);
		break;
	    case 'S':
		cmv_size = argtoll(optarg, NULL, NULL);
		break;
	/*  case 'M':
		buf_base = argtoll(optarg, NULL, NULL);
		break;
	    case 'Z':
		buf_size = argtoll(optarg, NULL, NULL);
		break; */
	    case '?':
	    default:
		err_flag++;
		break;
	    }
	}
	if (err_flag) {
	    fprintf(stderr, 
		"Usage: %s -[" OPTIONS "]\n"
		"%s -h for help.\n",
		cmd_name, cmd_name);
	    exit(2);
	}


	int fd = open(dev_mem, O_RDWR | O_SYNC);
	if (fd == -1) {
	    fprintf(stderr,
		"error opening >%s<.\n%s\n",
		dev_mem, strerror(errno));
	    exit(1);
	}

	if (cmv_addr == 0)
	    cmv_addr = cmv_base;

	void *base = mmap((void *)cmv_addr, cmv_size,
	    PROT_READ | PROT_WRITE, MAP_SHARED,
	    fd, cmv_base);
	if (base == (void *)-1) {
	    fprintf(stderr,
		"error mapping 0x%08lX+0x%08lX @0x%08lX.\n%s\n",
		(long)cmv_base, (long)cmv_size, (long)cmv_addr,
		strerror(errno));
	    exit(2);
	} else
	    cmv_addr = (long unsigned)base;

	fprintf(stderr,
	    "mapped 0x%08lX+0x%08lX to 0x%08lX.\n",
	    (long unsigned)cmv_base, (long unsigned)cmv_size,
	    (long unsigned)cmv_addr);

	void *buf = mmap((void *)map_addr, map_size,
	    PROT_READ | PROT_WRITE, MAP_SHARED,
	    fd, map_base);
	if (buf == (void *)-1) {
	    fprintf(stderr,
		"error mapping 0x%08lX+0x%08lX @0x%08lX.\n%s\n",
		(long)map_base, (long)map_size, (long)map_addr,
		strerror(errno));
	    exit(2);
	} else
	    map_addr = (long unsigned)buf;

	fprintf(stderr,
	    "mapped 0x%08lX+0x%08lX to 0x%08lX.\n",
	    (long unsigned)map_base, (long unsigned)map_size,
	    (long unsigned)map_addr);

	void *line = calloc(64*128, sizeof(uint16_t));
	if (line == (void *)-1) {
	    fprintf(stderr,
		"error allocating memory\n%s\n",
		strerror(errno));
	    exit(3);
	}

	for (int i=0; i<4; i++) {
	    if (buf_base[i] == -1)
		buf_base[i] = get_fil_reg(FIL_REG_BUF0 + 2*i);
	    if (buf_epat[i] == -1)
		buf_epat[i] = get_fil_reg(FIL_REG_PAT0 + 2*i);
	}

	uint32_t ovr = get_fil_reg(FIL_REG_OVERRIDE);

	uint32_t cavg[4096] = { 0 };
	uint32_t ravg[4096] = { 0 };

	if (opt_snap) {
	    set_fil_reg(FIL_REG_OVERRIDE, 0x0);
	    usleep(100000);
	}

	if (opt_zero && (opt_cols || !(opt_cols && opt_rows)))
	    apply_colc(cavg, (uint16_t[2]){ 0, 0 }, 1);
	if (opt_zero && (opt_rows || !(opt_cols && opt_rows)))
	    apply_rowc(ravg, (uint16_t[2]){ 0, 0 }, 1);

	for (int i=0; i<num_samples; i++) {

	    uint32_t cseq = get_fil_reg(FIL_REG_CSEQ);
	    uint32_t tgl = (cseq >> 31) & 0x1;
	    uint32_t status = get_fil_reg(FIL_REG_STATUS);
	    uint16_t wsel = (status >> 30) & 0x3;

	    if (opt_snap) {
		fprintf(stderr, "triggering image capture ...\n");

		set_fil_reg(FIL_REG_OVERRIDE, 0x01000100);
		usleep(10);
		set_fil_reg(FIL_REG_OVERRIDE, 0x0);

		fprintf(stderr, "waiting for sequencer ...\n");

		while (tgl == ((cseq >> 31) & 0x1))
		    cseq = get_fil_reg(FIL_REG_CSEQ);

		uint32_t addr = get_fil_reg(FIL_REG_ADDR);

		fprintf(stderr, "gen address = 0x%08lX\n",
		    (unsigned long)addr);
	    }

	    fprintf(stderr, "buffer base = 0x%08lX\n",
		(unsigned long)buf_base[wsel]);

	    uint64_t *dp = (uint64_t *)(map_addr + (buf_base[wsel] - map_base));

	    /* fprintf(stderr, "block[%d] = %03X,%03X,%03X,%03X\n", wsel,
		col_row(dp, 0, 0), col_row(dp, 1, 0),
		col_row(dp, 0, 1), col_row(dp, 1, 1)); */

	    fprintf(stderr, "buffer base = 0x%08lX\n",
		(unsigned long)buf_base[wsel]);

	    if (opt_cols)
		calc_avg_cols(dp, cavg);

	    if (opt_rows)
		calc_avg_rows(dp, ravg);
	}

	if (opt_snap)
	    set_fil_reg(FIL_REG_OVERRIDE, ovr);

	uint16_t cavg_mm[6];
	uint16_t ravg_mm[6];

	if (opt_cols) {
	    calc_min_max(cavg, cavg_mm, num_cols, num_samples);

	    apply_colc(cavg, &cavg_mm[4], num_samples);
	}

	if (opt_rows) {
	    calc_min_max(ravg, ravg_mm, num_rows, num_samples);

	    apply_rowc(ravg, &ravg_mm[4], num_samples);
	}

	if (opt_avg && opt_cols) {
	    for (int c=0; c<4096; c++)
		fprintf(stderr, "%d\t%d\n", c,
		    cavg[c] - cavg_mm[4 + (c&1)] * num_samples);

	    fprintf(stderr, "%d - %d - %d, %d - %d - %d\n",
		cavg_mm[0], cavg_mm[4], cavg_mm[2],
		cavg_mm[1], cavg_mm[5], cavg_mm[3]);
	}

	if (opt_avg && opt_rows) {
	    for (int r=0; r<3072; r++)
		fprintf(stderr, "%d\t%d\n", r,
		    ravg[r] - ravg_mm[4 + (r&1)] * num_samples);

	    fprintf(stderr, "%d - %d - %d, %d - %d - %d\n",
		ravg_mm[0], ravg_mm[4], ravg_mm[2],
		ravg_mm[1], ravg_mm[5], ravg_mm[3]);
	}

	exit((err_flag)?1:0);
}


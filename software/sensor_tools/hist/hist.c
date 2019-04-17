/**********************************************************************
**  hist.c
**	Dump Histogramm from Memory Buffer
**	Version 1.4
**
**  Copyright (C) 2013-2014 H.Poetzl
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

#define	VERSION	"cmv_hist3 V1.4"

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

static int16_t num_center = 100;
static int16_t num_decim = 1;
static int16_t num_bins = 4096;

static bool opt_snap = false;



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


#define	OPTIONS	"hsb:d:r:C:B:S:M:Z:"

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
		    "-s        acquire snapshot\n"
		    "-b <num>  number of bins\n"
		    "-d <num>  decimation factor\n"
		    "-r <num>  number of rows\n"
		    "-C <prc>  center sample area\n"
		    "-B <val>  register mapping base\n"
		    "-S <val>  register mapping size\n"
	//	    "-M <val>  buffer memory base\n"
	//	    "-Z <val>  buffer memory size\n"
		    , cmd_name);
		exit(0);
		break;
	    case 's':
		opt_snap = true;
		break;
	    case 'b':
		num_bins = argtoll(optarg, NULL, NULL);
		break;
	    case 'd':
		num_decim = argtoll(optarg, NULL, NULL);
		break;
	    case 'r':
		num_rows = argtoll(optarg, NULL, NULL);
		break;
	    case 'C':
		num_center = argtoll(optarg, NULL, NULL);
		break;
	    case 'B':
		cmv_base = argtoll(optarg, NULL, NULL);
		break;
	    case 'S':
		cmv_size = argtoll(optarg, NULL, NULL);
		break;
	 /* case 'M':
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

	for (int i=0; i<4; i++) {
	    if (buf_base[i] == -1)
		buf_base[i] = get_fil_reg(FIL_REG_BUF0 + 2*i);
	    if (buf_epat[i] == -1)
		buf_epat[i] = get_fil_reg(FIL_REG_PAT0 + 2*i);
	}

	uint32_t ovr = get_fil_reg(FIL_REG_OVERRIDE);
	uint32_t cseq = get_fil_reg(FIL_REG_CSEQ);
	uint32_t tgl = (cseq >> 31) & 0x1;
	uint32_t status = get_fil_reg(FIL_REG_STATUS);

	if (!opt_snap)
	    goto skip;

	fprintf(stderr, "triggering image capture ...\n");

	set_fil_reg(FIL_REG_OVERRIDE,	0x01000100);
	usleep(10);
	set_fil_reg(FIL_REG_OVERRIDE,	ovr);

	while (tgl == ((cseq >> 31) & 0x1))
	    cseq = get_fil_reg(FIL_REG_CSEQ);

	uint32_t addr = get_fil_reg(FIL_REG_ADDR);

	fprintf(stderr, "gen address = 0x%08lX\n",
	    (unsigned long)addr);

skip:	;

	uint16_t wsel = ((status >> 30) - 1) & 0x3;	/* FIXME: hack */
	fprintf(stderr,
	    "buffer = 0x%08lX\n",
	    (unsigned long)buf_base[wsel]);

	uint64_t *dp = (uint64_t *)(map_addr + (buf_base[wsel] - map_base));
	uint32_t hist[4][4096] = {{ 0 }};

	uint16_t rmin = num_rows * (100.0 - num_center)/200.0;
	uint16_t rmax = num_rows - rmin;
	uint16_t cmin = num_cols * (100.0 - num_center)/200.0;
	uint16_t cmax = num_cols - cmin;

	fprintf(stderr, "center region = (%d-%d)x(%d-%d)\n",
	    cmin, cmax, rmin, rmax);

	uint16_t sdec = num_decim * 2;
	uint16_t adec = num_decim - 1;
	uint32_t total = (rmax - rmin)/num_decim *
	    (cmax - cmin)/num_decim;

	fprintf(stderr, "sample decimation = %d (%d)\n",
	    num_decim, total);

	for (int r=0; r<num_rows; r+=sdec) {
	    for (int c=0; c<num_cols; c+=sdec) {
		register uint64_t val = *dp++;

		if ((r >= rmin) && (r < rmax) &&
		    (c >= cmin) && (c < cmax)) {

		    hist[0][(val >> 52) & 0xFFF]++;	/* CH0 */
		    hist[1][(val >> 40) & 0xFFF]++;	/* CH1 */
		    hist[2][(val >> 28) & 0xFFF]++;	/* CH2 */
		    hist[3][(val >> 16) & 0xFFF]++;	/* CH3 */
		}
		dp += adec;
	    }
	    dp += 2048 * adec;
	}

	uint32_t bin[4];
	float frem[4] = { 0.0 };
	float vd = 4096.0 / num_bins;

	for (int b=0; b<num_bins; b++) {
	    float vf = b * vd;

	    for (c=0; c<4; c++) {
	        uint16_t v = vf;

	    	frem[c] += (1 - (vf - v)) * hist[c][v];
		v++;
	        while (v < (int)(vf + vd)) {
		    frem[c] += hist[c][v];
		    v++;
		}
		if (v < (vf + vd))
		    frem[c] += (vf + vd - v) * hist[c][v];
		bin[c] = frem[c];
		frem[c] -= bin[c];
	    }

	    printf("%6d %6d %6d %6d\n",
		bin[0], bin[1], bin[2], bin[3]);
	}

	exit((err_flag)?1:0);
}


/**********************************************************************
**  mimg.c
**	Upload RGB or RAW Image to HDMI Memory
**	Version 1.8
**
**  Copyright (C) 2013-2016 H.Poetzl
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
#include <math.h>

#include "scn_reg.h"

#define	VERSION	"V1.8"

static char *cmd_name = NULL;

static uint32_t scn_base = 0x80000000;
static uint32_t scn_size = 0x00400000;

static uint32_t map_base = 0x18000000;
static uint32_t map_size = 0x08000000;

static uint32_t map_addr = 0x00000000;

static char *dev_mem = "/dev/mem";


static uint32_t num_tpat = 0;
static uint64_t num_pixel = 0;

static bool opt_word = false;
static bool opt_raw = false;
static bool opt_overlay = false;
static bool opt_colover = false;
static bool opt_all = false;
static bool opt_pixel = false;

static uint32_t buf_base[4] = { -1, -1, -1, -1 };
static uint32_t buf_epat[4] = { -1, -1, -1, -1 };


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
	    case '/':
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

#define	CH0 (64-12)
#define	CH1 (64-24)
#define CH2 (64-36)
#define CH3 (64-48)

static inline
uint64_t calc_tpat(unsigned num, unsigned col, unsigned row)
{
	switch (num) {
	    case 1: {
		unsigned rc = row / 32;
		uint64_t cv = col & 0xFFF;

		return ((rc & 1) ? (cv << CH0) : 0) |
		       ((rc & 2) ? (cv << CH1) : 0) |
		       ((rc & 4) ? (cv << CH2) : 0) |
		       ((rc & 8) ? (cv << CH3) : 0) |
		       ((rc & 0xF) << 12) | cv;
	    };
	    case 2: {
		unsigned rc = row / 32;
		uint64_t cv = (col & 0xFFF) << 1;

		return ((rc & 1) ? (cv << CH0) + 0 : 0) |
		       ((rc & 2) ? (cv << CH1) + 0 : 0) |
		       ((rc & 4) ? (cv << CH2) + 1 : 0) |
		       ((rc & 8) ? (cv << CH3) + 1 : 0) |
		       ((rc & 0xF) << 12) | (cv << 1);
	    };
	    case 3: {
		unsigned cc = col / 256;
		unsigned rc = row / 256;
		uint64_t cv = (col & 0xFF) << 4;
		uint64_t rv = (row & 0xFF) << 4;

		return ((cc & 1) ? (cv << CH0) : 0) |
		       ((cc & 2) ? (cv << CH1) : 0) |
		       ((rc & 1) ? (rv << CH2) : 0) |
		       ((rc & 2) ? (rv << CH3) : 0);
	    };
	    case 4: {
		float cf = col / (1920.0 - 1);
		float rf = row / (1080.0 - 1);
		float mf = (1<<12) - 1;
		uint64_t cr = (1-rf)*mf;
		uint64_t cg = cf*mf;
		uint64_t cb = rf*mf;

		return (cr << CH0) | (cg << CH1) |
		       (cg << CH2) | (cb << CH3);
	    };
	    case 5: {
		unsigned cb = (col & row & 0x80) ? (col >> 1) & 0xF : 0;
		unsigned cg = (col & row & 0x80) ? (row >> 1) & 0xF : 0;
		unsigned cr = (col & row & 0x80) ? ((col >> 5) & 0x3) | ((row >> 3) & 0xC) : 0;
		unsigned cc = (col & row & 0x80) ? ((col >> 8) & 0x3) | ((row >> 6) & 0xC) : 0;
		
		return (cc << 12) | (cr << 8) | (cg << 4) | cb;
	    };
	    case 6: {
		float cf = col / (1920.0 - 1);
		float rf = row / (1080.0 - 1);
		float mf = (1<<12) - 1;
		float h = cf * 6.0;
		float s = 1.0 - rf;
		float v = 1.0 * mf;
		int i = floor(h);
		float f = h -i;
		float p = v * (1 - s);
		float q = v * (1 - s * f);
		float t = v * (1 - s * (1 - f));
		uint64_t cr, cg, cb;
		
		switch (i) {
		case 0: cr = v; cg = t; cb = p; break;
		case 1: cr = q; cg = v; cb = p; break;
		case 2: cr = p; cg = v; cb = t; break;
		case 3: cr = p; cg = q; cb = v; break;
		case 4: cr = t; cg = p; cb = v; break;
		default: cr = v; cg = p; cb = q; break;
		}

		return (cr << CH0) | (cg << CH1) |
		       (cg << CH2) | (cb << CH3);
	    };
	    case 7: {
		float cf = col / (1920.0 - 1);
		float rf = row / (1080.0 - 1);
		float mf = (1<<12) - 1;
		float h = cf * 6.0;
		float s = 1.0;
		float v = (1.0 - rf) * mf;
		int i = floor(h);
		float f = h - i;
		float p = v * (1 - s);
		float q = v * (1 - s * f);
		float t = v * (1 - s * (1 - f));
		uint64_t cr, cg, cb;
		
		switch (i) {
		case 0: cr = v; cg = t; cb = p; break;
		case 1: cr = q; cg = v; cb = p; break;
		case 2: cr = p; cg = v; cb = t; break;
		case 3: cr = p; cg = q; cb = v; break;
		case 4: cr = t; cg = p; cb = v; break;
		default: cr = v; cg = p; cb = q; break;
		}

		return (cr << CH0) | (cg << CH1) |
		       (cg << CH2) | (cb << CH3);
	    };
	    default:
		return 0;
	}
}


const char *parse_addrs(const char *ptr, uint32_t *gr, uint32_t *gb)
{
	const char *sep = NULL;

	*gr = argtoll(ptr, &sep, strtoll);
	switch (sep[0]) {
	case ',':
	case ';':
	    ptr = sep + 1;
	    *gb = argtoll(ptr, &sep, strtoll);
	    break;
	}

	return sep;
}

static inline
void	push_val(uint16_t **ptr, uint16_t bits,
	uint16_t *bcnt, uint32_t *bbuf, uint16_t val)
{
	*bbuf = (*bbuf << bits) | (val >> (16 - bits));
	*bcnt += bits;

	while (*bcnt > 16) {
	    *(*ptr)++ = *bbuf >> (*bcnt - 16);
	    *bcnt -= 16;
	}
}

static
void	write_line(uint8_t *bp, uint64_t *dp, unsigned row)
{
	uint64_t val = 0;
	uint64_t mask = 0;
	unsigned inc;

	if (opt_colover)
	    inc = 4;
	else if (opt_word)
	    inc = 6;
	else
	    inc = 3;

	if (opt_overlay || opt_colover)
	    mask = 0xFFFF;
	else
	    mask = ~0xFFFF;

	for (unsigned col = 0; col < 1920; col++) {
	    if (opt_pixel) {
		val = num_pixel;
		if (!opt_overlay)
		    val <<= 16;
	    } else if (num_tpat) {
		val = calc_tpat(num_tpat, col, row);
	    } else {
		if (opt_overlay) {
		    val = (bp[1] > 0x80) ? 1 : 0;
		    val = (val << 8) | bp[0];
		    val = (val << 4);
		} else if (opt_colover) {
		    val = (bp[3] < 0x55) ? 0x0 :
			  ((bp[3] > 0xAA) ? 0x2 : 0x6);
		    val = (val << 4) | (bp[0] >> 4);
		    val = (val << 4) | (bp[1] >> 4);
		    val = (val << 4) | (bp[2] >> 4);
		    // val |= (bp[3] > 0x80) ? 0x1000 : 0x0000;
		} else if (opt_raw) {
		    val = bp[0];
		    val = (val << 8) | bp[1];
		    val = (val << 8) | bp[2];
		    val = (val << 8) | bp[3];
		    val = (val << 8) | bp[4];
		    val = (val << 8) | bp[5];
		    val = (val << 16);
		} else if (opt_word) {
		    val = (bp[1] << 4LL) | bp[0] >> 4LL;
		    val = (val << 12) | (bp[3] << 4LL) | (bp[2] >> 4LL);
		    val = (val << 12) | (bp[3] << 4LL) | (bp[2] >> 4LL);
		    val = (val << 12) | (bp[5] << 4LL) | (bp[4] >> 4LL);
		    val = (val << 16);
		} else {
		    val = (bp[0] << 4LL);
		    val = (val << 12) | (bp[1] << 4LL);
		    val = (val << 12) | (bp[1] << 4LL);
		    val = (val << 12) | (bp[2] << 4LL);
		    val = (val << 16);
		}
	    }
	    *dp = (*dp & ~mask) | (val & mask);
	    dp++;
	    bp += inc;
	}
}

int	main(int argc, char *argv[])
{
	extern int optind;
	extern char *optarg;
	int c, err_flag = 0;

#define	OPTIONS "haoOrwD:W:H:P:T:B:S:A:"

	cmd_name = argv[0];
	while ((c = getopt(argc, argv, OPTIONS)) != EOF) {
	    switch (c) {
	    case 'h':
		fprintf(stderr,
		    "This is %s " VERSION "\n"
		    "options are:\n"
		    "-h        print this help message\n"
		    "-a        load all buffers\n"
		    "-o        load as overlay\n"
		    "-O        load as color overlay\n"
		    "-r        load raw data\n"
		    "-w        use word sized data\n"
		    "-D <val>  image color depth\n"
		    "-W <val>  image width\n"
		    "-H <val>  image height\n"
		    "-P <val>  uniform pixel color\n"
		    "-T <val>  load test pattern\n"
		    "-B <val>  memory mapping base\n"
		    "-S <val>  memory mapping size\n"
		    "-A <val>  memory mapping address\n"
		    , cmd_name);
		exit(0);
		break;
	    case 'a':
		opt_all = true;
		break;
	    case 'o':
		opt_overlay = true;
		break;
	    case 'O':
		opt_colover = true;
		break;
	    case 'r':
		opt_raw = true;
		break;
	    case 'w':
		opt_word = true;
		break;
	    case 'P':
		num_pixel = argtoll(optarg, NULL, NULL);
		opt_pixel = true;
		break;
	    case 'T':
		num_tpat = argtoll(optarg, NULL, NULL);
		break;
	    case 'B':
		map_base = argtoll(optarg, NULL, NULL);
		break;
	    case 'S':
		map_size = argtoll(optarg, NULL, NULL);
		break;
	    case 'A':
		map_addr = argtoll(optarg, NULL, NULL);
		break;
	    case '?':
	    default:
		err_flag++;
		break;
	    }
	}
	if (err_flag) {
	    fprintf(stderr, 
		"Usage: %s -[" OPTIONS "] [file]\n"
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

	void *scnb = mmap((void *)scn_addr, scn_size,
	    PROT_READ | PROT_WRITE, MAP_SHARED,
	    fd, scn_base);
	if (scnb == (void *)-1) {
	    fprintf(stderr,
		"error mapping 0x%08lX+0x%08lX @0x%08lX.\n%s\n",
		(long)scn_base, (long)scn_size, (long)scn_addr,
		strerror(errno));
	    exit(2);
	} else
	    scn_addr = (long unsigned)scnb;

	fprintf(stderr,
	    "mapped 0x%08lX+0x%08lX to 0x%08lX.\n",
	    (long unsigned)scn_base, (long unsigned)scn_size,
	    (long unsigned)scn_addr);

	if (map_addr == 0)
	    map_addr = map_base;

	void *base = mmap((void *)map_addr, map_size,
	    PROT_READ | PROT_WRITE, MAP_SHARED,
	    fd, map_base);
	if (base == (void *)-1) {
	    fprintf(stderr,
		"error mapping 0x%08lX+0x%08lX @0x%08lX.\n%s\n",
		(long)map_base, (long)map_size, (long)map_addr,
		strerror(errno));
	    exit(2);
	}

	fprintf(stderr,
	    "mapped 0x%08lX+0x%08lX to 0x%08lX.\n",
	    (long unsigned)map_base, (long unsigned)map_size,
	    (long unsigned)base);


	if (argc > optind) {
	    close(0);
	    open(argv[optind], O_RDONLY, 0);
	}

	for (int i=0; i<4; i++) {
	    if (buf_base[i] == -1)
		buf_base[i] = get_gen_reg(GEN_REG_BUF0 + 2*i);
	    if (buf_epat[i] == -1)
		buf_epat[i] = get_gen_reg(GEN_REG_PAT0 + 2*i);
	}

	uint16_t rsel = (get_gen_reg(GEN_REG_STATUS) >> 30) & 0x3;

	fprintf(stderr,
	    "read buffer = 0x%08lX\n",
	    (unsigned long)buf_base[rsel]);
	
	for (unsigned row = 0; row < 1080; row++) {
	    uint8_t buf[1920*6];
	    uint8_t *bp = buf;
	    size_t buf_size;

	    if (opt_colover)
		buf_size = 1920*4;
	    else if (opt_overlay)
		buf_size = 1920*1;
	    else
		buf_size = 1920*3;

	    if (opt_word)
		buf_size *= 2;

	    if ((num_tpat == 0) && !opt_pixel) {
		size_t total = 0;
		while (total < buf_size) {
		    size_t len = read(0, bp, buf_size - total);
	
		    if (len == 0)
			exit(1);
		    if (len < 0)
			exit(2);
	
		    total += len;
		    bp += len;
		}
	    }

	    bp = buf;

	    if (opt_all) {
		for (int i = 0; i < 4; i++) {
		    uint32_t dp_base = map_addr + (buf_base[i] - map_base);
		    uint64_t *dp = (uint64_t *)(dp_base + row * 16384);
		    
		    write_line(bp, dp, row);
		}
	    } else {
		uint32_t dp_base = map_addr + (buf_base[rsel] - map_base);
		uint64_t *dp = (uint64_t *)(dp_base + row * 16384);

		write_line(bp, dp, row);
	    }
	}

	exit((err_flag)?1:0);
}


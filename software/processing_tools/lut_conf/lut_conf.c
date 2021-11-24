/**********************************************************************
**  lut_conf3.c
**	Configure LUT Table
**	Version 1.5
**
**  SPDX-FileCopyrightText: © 2014 Herbert Poetzl <herbert@13thfloor.at>
**  SPDX-License-Identifier: GPL-2.0-or-later
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


#define	VERSION	"lut_conf3 V1.5"

static char *cmd_name = NULL;


static uint32_t lut_base = 0x80300000;
static uint32_t lut_size = 0x00004000;

static uint32_t lut_addr = 0x00000000;

static char *dev_mem = "/dev/mem";

static float val_gamma = 1.0;
static float val_factor = 1.0;
static float val_scale = 1.0;
static float val_offset = 0.0;
static float val_center = 0.0;

static int32_t num_minval = 0;
static int32_t num_maxval = 65535;
static uint32_t num_entries = 4096;

static bool opt_dump = false;
static bool opt_read = false;
static bool opt_write = false;
static bool opt_wrap = false;
static bool opt_sine = false;
static bool opt_sigmoid = false;


#define min(a, b)	(((a) < (b)) ? (a) : (b))
#define max(a, b)	(((a) > (b)) ? (a) : (b))


typedef long long int (stoll_t)(const char *, char **, int);

long long int argtoll(
	const char *str, const char **end, stoll_t stoll)
{
	int bit, inv = 0, neg = 0;
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
	    break;
	case '-':
	    neg = 1;	/* negate */
	    str++;
	    break;
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

	if (neg)
	    val = -val;
	return (inv)?~(val):(val);
}


uint16_t get_lut_reg(unsigned reg)
{
	volatile uint32_t *ptr = (uint32_t *)(lut_addr);
	return ptr[reg] & 0xFFFF;
}

void	set_lut_reg(unsigned reg, int32_t val)
{
	volatile uint32_t *ptr = (uint32_t *)(lut_addr);
	ptr[reg] = val;
}



int	msb_set(uint32_t val)
{
	for (int b=31; b>0; b--)
	    if ((val >> b) & 1)
		return b;

	return -1;
}

int	lsb_set(uint32_t val)
{
	for (int b=0; b<32; b++)
	    if ((val >> b) & 1)
		return b;

	return -1;
}


int	main(int argc, char *argv[])
{
	extern int optind;
	extern char *optarg;
	int c, err_flag = 0;

#define	OPTIONS "hdrwzs:m:N:M:C:F:O:B:S:A:G:"

	cmd_name = argv[0];
	while ((c = getopt(argc, argv, OPTIONS)) != EOF) {
	    switch (c) {
	    case 'h':
		fprintf(stderr,
		    "This is %s " VERSION "\n"
		    "options are:\n"
		    "-h        print this help message\n"
		    "-d        dump current values\n"
		    "-r        read index/value pairs\n"
		    "-w        write index/value pairs\n"
		    "-z        wrap on limits\n"
		    "-s <val>  scale input value\n"
		    "-m <val>  minimum output value\n"
		    "-N <val>  number of lut entries\n"
		    "-M <val>  maximum output value\n"
		    "-C <val>  sigmoid/sine center\n"
		    "-F <val>  output value factor\n"
		    "-O <val>  output value offset\n"
		    "-B <val>  memory mapping base\n"
		    "-S <val>  memory mapping size\n"
		    "-A <val>  memory mapping address\n"
		    "-G <val>  gamma value\n"
		    , cmd_name);
		exit(0);
		break;
	    case 'd':
		opt_dump = true;
		break;
	    case 'r':
		opt_read = true;
		break;
	    case 'w':
		opt_write = true;
		break;
	    case 'z':
		opt_wrap = true;
		break;
	    case 'm':
		num_minval = argtoll(optarg, NULL, NULL);
		break;
	    case 's':
		val_scale = strtof(optarg, NULL);
		opt_sine = true;
		break;
	    case 'N':
		num_entries = argtoll(optarg, NULL, NULL);
		break;
	    case 'M':
		num_maxval = argtoll(optarg, NULL, NULL);
		break;
	    case 'C':
		val_center = strtof(optarg, NULL);
		opt_sigmoid = true;
		break;
	    case 'F':
		val_factor = strtof(optarg, NULL);
		break;
	    case 'O':
		val_offset = strtof(optarg, NULL);
		break;
	    case 'B':
		lut_base = argtoll(optarg, NULL, NULL);
		break;
	    case 'S':
		lut_size = argtoll(optarg, NULL, NULL);
		break;
	    case 'A':
		lut_addr = argtoll(optarg, NULL, NULL);
		break;
	    case 'G':
		val_gamma = strtof(optarg, NULL);
		break;
	    case '?':
	    default:
		err_flag++;
		break;
	    }
	}
	if (err_flag) {
	    fprintf(stderr, 
		"Usage: %s -[" OPTIONS "] ...\n"
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

	if (lut_addr == 0)
	    lut_addr = lut_base;

	void *base = mmap((void *)lut_addr, lut_size,
	    PROT_READ | PROT_WRITE, MAP_SHARED,
	    fd, lut_base);
	if (base == (void *)-1) {
	    fprintf(stderr,
		"error mapping 0x%08lX+0x%08lX @0x%08lX.\n%s\n",
		(long)lut_base, (long)lut_size, (long)lut_addr,
		strerror(errno));
	    exit(2);
	} else
	    lut_addr = (long unsigned)base;

	fprintf(stderr,
	    "mapped 0x%08lX+0x%08lX to 0x%08lX.\n",
	    (long unsigned)lut_base, (long unsigned)lut_size,
	    (long unsigned)lut_addr);

	if (opt_dump) {
	    for (int i=0; i<num_entries; i++) {
		uint32_t v = get_lut_reg(i);

		printf("%4d %d\n", i, v);
	    }
	} else if (opt_read) {
	    while (!feof(stdin)) {
		unsigned i, n;
		float v;

		n = fscanf(stdin, "%d %f", &i, &v);
		v *= val_factor;
		v += val_offset;

		set_lut_reg(i % num_entries,
		    max(min(v, num_maxval), 0));
	    }
	} else {
	    for (int i=0; i<num_entries; i++) {
		float v;
		float x = i * val_scale / num_entries;
		float f = val_factor * num_maxval;

		if (opt_sine)
		    v = sin(x - val_center) * num_maxval * val_factor;
		else if (opt_sigmoid)
		    v = 1.0 * num_maxval /
			(1.0 + exp((x - val_center) * val_factor));
		else
		    v = pow(x, val_gamma) * f;

		v += val_offset;
		if (opt_wrap)
		    v = fmod((v - num_minval),
			num_maxval - num_minval) + num_minval;
		else
		    v = max(min(v, num_maxval), num_minval);

		if (opt_write)
		    printf("%4d %f\n", i, v);
		else
		    set_lut_reg(i, v);
	    }
	}

	exit((err_flag)?1:0);
}


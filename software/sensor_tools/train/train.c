/**********************************************************************
**  train.c
**	Train image sensor (currently CMV12000) LVDS channels
**	Version 1.3
**
**  SPDX-FileCopyrightText: © 2013 Herbert Poetzl <herbert@13thfloor.at>
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

#include "cmv_reg.h"


#define	VERSION	"cmv_train3 V1.3"

static char *cmd_name = NULL;

static uint32_t sys_base = 0xF8000000;
static uint32_t sys_size = 0x00001000;

static uint32_t sys_addr = 0xF8000000;

static uint32_t cmv_base = 0x60000000;
static uint32_t cmv_size = 0x00400000;

static char *dev_mem = "/dev/mem";

static uint32_t pattern = 0xA95;

static bool opt_all = false;


#define min(a, b)	(((a) < (b)) ? (a) : (b))
#define max(a, b)	(((a) > (b)) ? (a) : (b))


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


uint32_t get_sys_reg(unsigned reg)
{
	volatile uint32_t *ptr = (uint32_t *)(sys_addr);
	return ptr[reg];
}

void	set_sys_reg(unsigned reg, uint32_t val)
{
	volatile uint32_t *ptr = (uint32_t *)(sys_addr);
	ptr[reg] = val;
}


void	cmv_bitslip(unsigned chan)
{
	set_del_reg(chan, 0x80000000);
	usleep(100);
}


int	num_bits(uint32_t val)
{
	uint32_t ret = 0;

	for (int b=0; b<32; b++)
	    if ((val >> b) & 1)
		ret++;

	return ret;
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


uint32_t cmv_check(unsigned chan, unsigned delay)
{
	uint32_t val, ret = 0;

	for (int d=0; d<32; d++) {
	    set_del_reg(chan, d);

	    if (delay) usleep(delay);
	    val = get_del_reg(chan);
	
	    if ((val & 0x30000000) == 0x20000000)
		ret |= (1 << d);
	}

	return ret;
}

int	cmv_good(unsigned chan)
{
	uint32_t val;

	usleep(10);
	val = get_del_reg(chan);

	if ((val & 0x30000000) == 0x20000000)
	    return 1;
	
	return 0;
}


int	main(int argc, char *argv[])
{
	extern int optind;
	extern char *optarg;
	int c, err_flag = 0;

	cmd_name = argv[0];
	while ((c = getopt(argc, argv, "haB:S:A:P:")) != EOF) {
	    switch (c) {
	    case 'h':
		fprintf(stderr,
		    "This is %s " VERSION "\n"
		    "options are:\n"
		    "-h        print this help message\n"
		    "-a        test all bit pattern\n"
		    "-B <val>  memory mapping base\n"
		    "-S <val>  memory mapping size\n"
		    "-A <val>  memory mapping address\n"
		    "-P <val>  training pattern\n"
		    , cmd_name);
		exit(0);
		break;
	    case 'a':
		opt_all = true;
		break;
	    case 'B':
		cmv_base = argtoll(optarg, NULL, NULL);
		break;
	    case 'S':
		cmv_size = argtoll(optarg, NULL, NULL);
		break;
	    case 'A':
		cmv_addr = argtoll(optarg, NULL, NULL);
		break;
	    case 'P':
		pattern = argtoll(optarg, NULL, NULL) & 0xFFF;
		break;
	    case '?':
	    default:
		err_flag++;
		break;
	    }
	}
	if (err_flag) {
	    fprintf(stderr, 
		"Usage: %s -[hvB:S:E:] path ...\n"
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

	void *sysr = mmap((void *)sys_addr, sys_size,
	    PROT_READ | PROT_WRITE, MAP_SHARED,
	    fd, sys_base);
	if (sysr == (void *)-1) {
	    fprintf(stderr,
		"error mapping 0x%08lX+0x%08lX @0x%08lX.\n%s\n",
		(long)sys_base, (long)sys_size, (long)sys_addr,
		strerror(errno));
	    exit(2);
	} else
	    sys_addr = (long unsigned)sysr;

	fprintf(stderr,
	    "mapped 0x%08lX+0x%08lX to 0x%08lX.\n",
	    (long unsigned)sys_base, (long unsigned)sys_size,
	    (long unsigned)sys_addr);


	// uint32_t reset = get_sys_reg(144);
	// set_sys_reg(144, reset & ~2);	/* serdes reset		*/
	// set_sys_reg(144, reset | 2);		/* serdes enable	*/

	set_fil_reg(FIL_REG_OVERRIDE, 0x00FF0004);	// debug override

	printf("initial control adjustment ...\n");

	set_del_reg(33, 0x10);

	for (int w=0; w<2; w++) {
	    bool done = false;

	    for (int s=0; s<6; s++) {			/* bitslip	*/
		for (int d=0; d<32; d++) {		/* delay	*/
		    set_del_reg(32, d);
		    if (cmv_good(32))			/* first match	*/
			done = true;
		    if (done) break;
		}
		if (done) break;
		cmv_bitslip(32);
	    }
	    if (done) break;
	    cmv_bitslip(33);
	}

	printf("adjusting out delay ...\n");

	uint32_t dly_bmin = 0;
	uint32_t dly_out = 0x1F;

	set_fil_reg(FIL_REG_PATTERN, pattern);
	set_cmv_reg(89, pattern);

	for (int o=0; o<32; o++) {
	    uint32_t bmin = 31;
	    set_del_reg(33, o);

	    for (int c=0; c<33; c++) {
		uint32_t val, num, bnum = 0;
		
		for (int s=0; s<6; s++) {		/* bitslip	*/
		    val = cmv_check(c, 0);		/* check delay	*/
		    num = num_bits(val);
		
		    if (num > bnum)			/* keep max	*/
			bnum = num;

		    cmv_bitslip(c);
		}

		if (bnum < bmin)			/* keep min	*/
		    bmin = bnum;
	    }

	    if (bmin > dly_bmin) {			/* keep best	*/
		dly_out = o;
		dly_bmin = bmin;
	    }
	    printf("[%02d] = %02d\n", o, bmin);
	}

	printf("found maximum at %02d\n", dly_out);
	set_del_reg(33, dly_out);

	printf("adjusting input delays ...\n");

	set_fil_reg(FIL_REG_PATTERN, pattern);
	set_cmv_reg(89, pattern);

	// uint32_t dly_in[33] = { 0 };

	for (int c=0; c<33; c++) {
	    uint32_t bslip = 0;				/* best slip	*/
	    uint32_t bsnum = 0;				/* best value	*/

	    for (int s=0; s<6; s++) {
		uint32_t val = cmv_check(c, 10);
		uint32_t num = num_bits(val);
		
		if (bsnum < num) {
		    bslip = s;
		    bsnum = num;
		}
		
		cmv_bitslip(c);
	    }

	    for (int s=0; s<bslip; s++)
		cmv_bitslip(c);

	    uint32_t val = cmv_check(c, 10);
	    uint32_t num = num_bits(val);
	    uint32_t dly;

	    if (val == 0xFFFFFFFF ) {			/* center	*/
		printf("[%02d] 0x%08X center  ", c, val);
		dly = 0x10;
	    } else if (val < 0x80000000 ) {
		int msb = msb_set(val);			/* right	*/
		printf("[%02d] 0x%08X msb = %02d", c, val, msb);
		dly = max(0x00, msb - 16);
	    } else {
		int lsb = lsb_set(val);			/* left		*/
		printf("[%02d] 0x%08X lsb = %02d", c, val, lsb);
		dly = min(0x1F, lsb + 16);
	    }

	    printf(" => %02d (%2d,%2d)\n", dly, num, bsnum);
	    // dly_in[c] = dly;
	    set_del_reg(c, dly);
	}

	set_fil_reg(FIL_REG_OVERRIDE, 0x00FF0000);	// debug override


	uint32_t check = 0xFFFFFFFF;

	if (opt_all) {
	    printf("checking all bit pattern ...\n");

	    for (int p=0; p<(1<<12); p++) {
		set_fil_reg(FIL_REG_PATTERN, p);
		set_cmv_reg(89, p);
		
		usleep(100);
		check &= get_fil_reg(FIL_REG_MATCH);
		check &= ~get_fil_reg(FIL_REG_MISMATCH);
	    }
	} else {
	    printf("checking bit pattern ...\n");

	    for (int b=0; b<12; b++) {
		set_fil_reg(FIL_REG_PATTERN, (1 << b));
		set_cmv_reg(89, (1 << b));
	
		usleep(50000);
		check &= get_fil_reg(FIL_REG_MATCH);
		check &= ~get_fil_reg(FIL_REG_MISMATCH);
	    }

	    for (int b=0; b<12; b++) {
		set_fil_reg(FIL_REG_PATTERN, ~(1 << b));
		set_cmv_reg(89, ~(1 << b));
	
		usleep(50000);
		check &= get_fil_reg(FIL_REG_MATCH);
		check &= ~get_fil_reg(FIL_REG_MISMATCH);
	    }
	}

	printf("result = 0x%08X\n", check);

	set_fil_reg(FIL_REG_OVERRIDE, 0x00000000);	// unlock override
	set_fil_reg(FIL_REG_PATTERN, pattern);
	set_cmv_reg(89, pattern);

	exit((err_flag)?1:((check ^ 0xFFFFFFFF)?2:0));
}


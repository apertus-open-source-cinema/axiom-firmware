/**********************************************************************
**  cmv_perf3.c
**	Performance Monitor
**	Version 1.0
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
#include "scn_reg.h"

#define	VERSION	"V1.0"

static char *cmd_name = NULL;

static uint32_t cmv_base = 0x60000000;
static uint32_t cmv_size = 0x00400000;

static uint32_t scn_base = 0x80000000;
static uint32_t scn_size = 0x00400000;

static char *dev_mem = "/dev/mem";

static uint64_t num_time = 0;
static uint64_t num_delay = 100000;

static bool opt_frame = false;
static bool opt_memory = false;

double lvds = 300e6;
double bits = 12;
double channels = 32;

#define	CLOCK_ID	CLOCK_REALTIME

#define	XLINE_EO2
// #define	XLINE_EO16


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
double	ns_to_us(double val)
{
	return val * 1e-3;
}

static inline
double	ns_to_ms(double val)
{
	return val * 1e-6;
}

static inline
double	ns_to_s(double val)
{
	return val * 1e-9;
}


static inline
double	s_to_ns(double val)
{
	return val * 1e9;
}

static inline
double	ms_to_ns(double val)
{
	return val * 1e6;
}

static inline
double	us_to_ns(double val)
{
	return val * 1e3;
}


static inline
double	delta_ns(struct timespec *a, struct timespec *b)
{
	double delta = b->tv_nsec - a->tv_nsec;

	return delta + (b->tv_sec - a->tv_sec) * 1e9;
}

static inline
double	delta_us(struct timespec *a, struct timespec *b)
{
	return ns_to_us(delta_ns(a, b));
}

static inline
double	delta_ms(struct timespec *a, struct timespec *b)
{
	return ns_to_ms(delta_ns(a, b));
}

static inline
double	delta_s(struct timespec *a, struct timespec *b)
{
	return ns_to_s(delta_ns(a, b));
}


#define	OPTIONS	"hfmD:T:"

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
		    "-f        measure frame rates\n"
		    "-m        measure memory bandwidth\n"
		    "-D <val>  delay between updates\n"
		    "-T <val>  run for a given time\n"
		    , cmd_name);
		exit(0);
		break;
	    case 'f':
		opt_frame = true;
		break;
	    case 'm':
		opt_memory = true;
		break;
	    case 'D':
		num_delay = argtoll(optarg, NULL, NULL);
		break;
	    case 'T':
		num_time = argtoll(optarg, NULL, NULL);
		break;
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

	if (scn_addr == 0)
	    scn_addr = scn_base;

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


	struct timespec time_base;
	uint64_t hdmi_fcnt = 0;
	uint64_t cseq_fcnt = 0;

	uint32_t hdmi_fcnt_prev;
	uint32_t cseq_fcnt_prev;

	uint32_t hdmi_fcnt_max = get_scn_reg(SCN_REG_TOTALF);
	uint32_t cseq_fcnt_max = 4096;

	clock_gettime(CLOCK_ID, &time_base);
	hdmi_fcnt_prev = (get_scn_reg(SCN_REG_STATUS) >> 16) & 0xFFF;
	cseq_fcnt_prev = (get_fil_reg(FIL_REG_CSEQ) >> 16) & 0xFFF;

	while (1) {
	    struct timespec now;
	    uint32_t hdmi_fcnt_now;
	    uint32_t cseq_fcnt_now;

	    clock_gettime(CLOCK_ID, &now);
	    hdmi_fcnt_now = (get_scn_reg(SCN_REG_STATUS) >> 16) & 0xFFF;
	    cseq_fcnt_now = (get_fil_reg(FIL_REG_CSEQ) >> 16) & 0xFFF;

	    double delta = delta_s(&time_base, &now);

	    if (hdmi_fcnt_now >= hdmi_fcnt_prev)
		hdmi_fcnt += hdmi_fcnt_now - hdmi_fcnt_prev;
	    else
		hdmi_fcnt += hdmi_fcnt_now + hdmi_fcnt_max - hdmi_fcnt_prev;
	    hdmi_fcnt_prev = hdmi_fcnt_now;

	    if (cseq_fcnt_now >= cseq_fcnt_prev)
		cseq_fcnt += cseq_fcnt_now - cseq_fcnt_prev;
	    else
		cseq_fcnt += cseq_fcnt_now + cseq_fcnt_max - cseq_fcnt_prev;
	    cseq_fcnt_prev = cseq_fcnt_now;

	    printf("hdmi: %5.2f FPS\t cseq: %5.2f FPS\r",
		hdmi_fcnt / delta,
		cseq_fcnt / delta);

	    usleep(num_delay);
	}


	exit((err_flag)?1:0);
}


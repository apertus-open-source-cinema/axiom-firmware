
/***********************************************************************
**
**  memtool.c
**
**  Copyright (C) 2020-2021 Herbert Poetzl
**
**  Memory Tool
**
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License version 2 as
**  published by the Free Software Foundation.
**
***********************************************************************/


#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>



static char *cmd_name = NULL;

static uint64_t num_fill = 0L;
static uint64_t num_wdat = 0L;
static uint16_t num_cols = 0;

static bool opt_num = false;
static bool opt_dump = false;
static bool opt_read = false;
static bool opt_write = false;

static bool opt_check = false;
static bool opt_fill = false;
static bool opt_lfsr = false;
static bool opt_cols = false;

static bool opt_quiet = false;
static bool opt_verb = false;

static bool opt_rreg = false;
static bool opt_wreg = false;

static enum {
	DS_0 = 0,
	DS_8 = 8,
	DS_16 = 16,
	DS_32 = 32,
	DS_64 = 64,
} opt_ds = DS_0;

const char *mem_dev = "/dev/mem";

static int mem_fd = 0;
static void *map_ptr = NULL;
static void *mem_ptr = NULL;
static unsigned mem_prot = 0;
static uint32_t map_addr = 0L;
static uint32_t mem_addr = 0L;
static uint32_t map_size = 0L;
static uint32_t mem_size = 0L;
static uint32_t page_size = 0L;


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

static inline
uint8_t lfsr_7(uint8_t val)
{
	uint8_t rol = (val << 1) | ((val >> 6) & 1);
	return (rol ^ ((val >> 5) & 1)) & 0x7F;
}

static inline
uint16_t lfsr_15(uint16_t val)
{
	uint16_t rol = (val << 1) | ((val >> 14) & 1);
	return (rol ^ ((val >> 13) & 1)) & 0x7FFF;
}

static inline
uint32_t lfsr_31(uint32_t val)
{
	uint32_t rol = (val << 1) | ((val >> 30) & 1);
	return (rol ^ ((val >> 27) & 1)) & 0x7FFFFFFF;
}

static inline
uint64_t lfsr_63(uint64_t val)
{
	uint64_t rol = (val << 1) | ((val >> 62) & 1);
	return (rol ^ ((val >> 61) & 1)) & 0x7FFFFFFFFFFFFFFFL;
}

static inline
uint8_t lfsr_8(uint8_t val)
{
	uint8_t rol = (val << 1) | ((val >> 7) & 1);
	uint8_t xor = (val >> 5) ^ (val >> 4) ^ (val >> 3);
	return rol ^ (xor & 1);
}

static inline
uint16_t lfsr_16(uint16_t val)
{
	uint16_t rol = (val << 1) | ((val >> 15) & 1);
	uint16_t xor = (val >> 14) ^ (val >> 12) ^ (val >> 3);
	return rol ^ (xor & 1);
}

static inline
uint32_t lfsr_32(uint32_t val)
{
	uint32_t rol = (val << 1) | ((val >> 31) & 1);
	uint32_t xor = (val >> 21) ^ (val >> 1) ^ (val >> 0);
	return rol ^ (xor & 1);
}

static inline
uint64_t lfsr_64(uint64_t val)
{
	uint64_t rol = (val << 1) | ((val >> 63) & 1);
	uint64_t xor = (val >> 62) ^ (val >> 60) ^ (val >> 59);
	return rol ^ (xor & 1);
}


static void fill_u8(uint8_t *ptr, uint32_t cnt, uint8_t val)
{
	while (cnt--)
	    *ptr++ = val;
}

static void fill_u16(uint16_t *ptr, uint32_t cnt, uint16_t val)
{
	while (cnt--)
	    *ptr++ = val;
}

static void fill_u32(uint32_t *ptr, uint32_t cnt, uint32_t val)
{
	while (cnt--)
	    *ptr++ = val;
}

static void fill_u64(uint64_t *ptr, uint32_t cnt, uint64_t val)
{
	while (cnt--)
	    *ptr++ = val;
}


static void lfsr_u8(uint8_t *ptr, uint32_t cnt, uint8_t val)
{
	while (cnt--) {
	    *ptr++ = val;
	    val = lfsr_8(val);
	}
}

static void lfsr_u16(uint16_t *ptr, uint32_t cnt, uint16_t val)
{
	while (cnt--) {
	    *ptr++ = val;
	    val = lfsr_16(val);
	}
}

static void lfsr_u32(uint32_t *ptr, uint32_t cnt, uint32_t val)
{
	while (cnt--) {
	    *ptr++ = val;
	    val = lfsr_32(val);
	}
}

static void lfsr_u64(uint64_t *ptr, uint32_t cnt, uint64_t val)
{
	while (cnt--) {
	    *ptr++ = val;
	    val = lfsr_64(val);
	}
}


static uint32_t check_u8(uint8_t *ptr, uint32_t cnt, uint8_t val)
{
	while (cnt--)
	    if (*ptr++ != val)
		break;
	return cnt + 1;
}

static uint32_t check_u16(uint16_t *ptr, uint32_t cnt, uint16_t val)
{
	while (cnt--)
	    if (*ptr++ != val)
		break;
	return cnt + 1;
}

static uint32_t check_u32(uint32_t *ptr, uint32_t cnt, uint32_t val)
{
	while (cnt--)
	    if (*ptr++ != val)
		break;
	return cnt + 1;
}

static uint32_t check_u64(uint64_t *ptr, uint32_t cnt, uint64_t val)
{
	while (cnt--)
	    if (*ptr++ != val)
		break;
	return cnt + 1;
}


static uint32_t clfsr_u8(uint8_t *ptr, uint32_t cnt, uint8_t val)
{
	while (cnt--) {
	    if (*ptr++ != val)
		break;
	    val = lfsr_8(val);
	}
	return cnt + 1;
}

static uint32_t clfsr_u16(uint16_t *ptr, uint32_t cnt, uint16_t val)
{
	while (cnt--) {
	    if (*ptr++ != val)
		break;
	    val = lfsr_16(val);
	}
	return cnt + 1;
}

static uint32_t clfsr_u32(uint32_t *ptr, uint32_t cnt, uint32_t val)
{
	while (cnt--) {
	    if (*ptr++ != val)
		break;
	    val = lfsr_32(val);
	}
	return cnt + 1;
}

static uint32_t clfsr_u64(uint64_t *ptr, uint32_t cnt, uint64_t val)
{
	while (cnt--) {
	    if (*ptr++ != val)
		break;
	    val = lfsr_64(val);
	}
	return cnt + 1;
}


static void action(const char *name)
{
	if (opt_quiet || !opt_verb)
	    return;

	fprintf(stderr,
	    "%s memory 0x%08X @0x%08X.\n",
	    name, mem_size, mem_addr);
}


#define VERSION "V0.4"
#define	OPTIONS "h1248dlnqrvwC:F:N:RW:"

int main(int argc, char *argv[])
{
	extern int optind;
	extern char *optarg;
	int c, err_flag = 0;

	cmd_name = argv[0];

	while ((c = getopt(argc, argv, OPTIONS)) != EOF) {
	    switch (c) {
	    case 'h':
		fprintf(stderr, "This is %s %s\n"
		    "Options are:\n"
		    "\t-h        print this help message\n"
		    "\t-1        byte size (8 bit) data\n"
		    "\t-2        half word (16 bit) data\n"
		    "\t-4        word size (32 bit) data\n"
		    "\t-8        double word (64 bit) data\n"
		    "\t-d        dump memory\n"
		    "\t-l        use LFSR for data\n"
		    "\t-n        number of words not size\n"
		    "\t-q        quiet operation\n"
		    "\t-r        read data from memory\n"
		    "\t-v        be verbose about actions\n"
		    "\t-w        write data to memory\n"
		    "\t-C <val>  check memory\n"
		    "\t-F <val>  fill memory\n"
		    "\t-N <val>  number of columns\n"
		    "\t-R        read memory location\n"
		    "\t-W <val>  write memory location\n"
		    , cmd_name, VERSION);
		exit(0);

	    case '1':
		opt_ds = DS_8;
		break;
	    case '2':
		opt_ds = DS_16;
		break;
	    case '4':
		opt_ds = DS_32;
		break;
	    case '8':
		opt_ds = DS_64;
		break;

	    case 'n':
		opt_num = true;
		break;
	    case 'd':
		opt_dump = true;
		break;
	    case 'l':
		opt_lfsr = true;
		break;
	    case 'q':
		opt_quiet = true;
		break;
	    case 'r':
		opt_read = true;
		break;
	    case 'v':
		opt_verb = true;
		break;
	    case 'w':
		opt_write = true;
		break;

	    case 'C':
		opt_check = true;
		num_fill = argtoll(optarg, NULL, NULL);
		break;
	    case 'F':
		opt_fill = true;
		num_fill = argtoll(optarg, NULL, NULL);
		break;
	    case 'N':
		opt_cols = true;
		num_cols = argtoll(optarg, NULL, NULL);
		break;
	    case 'R':
		opt_rreg = true;
		break;
	    case 'W':
		opt_wreg = true;
		num_wdat = argtoll(optarg, NULL, NULL);
		break;

	    default:
		err_flag++;
		break;
	    }
	}

	if (argc > optind) {
	    mem_addr = argtoll(argv[optind++], NULL, NULL);
	} else {
	    err_flag++;
	}

	if (argc > optind) {
	    mem_size = argtoll(argv[optind++], NULL, NULL);
	}

	if (err_flag) {
	    if (!opt_quiet)
		fprintf(stderr,
		    "Usage: %s -[" OPTIONS "] <addr> <size>\n"
		    "%s -h for help.\n",
		    cmd_name, cmd_name);
	    exit(1);
	}

	page_size = getpagesize();

	if (opt_ds == DS_0)
	    opt_ds = DS_32;

	if (opt_rreg || opt_wreg) {
	    mem_size = opt_ds/8; 
	    goto rskip;
	}

	if (opt_num) {
	    mem_size *= (opt_ds/8);
	}

	if (!opt_cols) {
	    switch (opt_ds) {
	    case DS_8:
		num_cols = 16;
		break;
	    case DS_16:
		num_cols = 8;
		break;
	    case DS_32:
		num_cols = 6;
		break;
	    case DS_64:
		num_cols = 4;
		break;
	    default:
		num_cols = 1;
		break;
	    }
	}

rskip:
	mem_fd = open(mem_dev, O_RDWR | O_SYNC);
	if (mem_fd == -1) {
	    if (!opt_quiet)
		fprintf(stderr,
		    "error opening >%s<.\n%s\n",
		    mem_dev, strerror(errno));
	    exit(2);
	}

	map_addr = mem_addr & ~(page_size-1);
	map_size = mem_size + (mem_addr - map_addr);

	mem_prot = PROT_READ |
	    ((opt_write || opt_fill || opt_wreg) ? PROT_WRITE : 0);
	map_ptr = mmap(NULL, map_size, mem_prot,
	    MAP_SHARED, mem_fd, map_addr);
	if (map_ptr == (void *)-1) {
	    if (!opt_quiet)
		fprintf(stderr,
		    "error mapping 0x%08X @0x%08X.\n%s\n",
		    map_size, map_addr, strerror(errno));
	    exit(3);
	}

	mem_ptr = map_ptr + (mem_addr - map_addr);
	action("mapped");

	if (opt_rreg || opt_wreg)
	    goto rmode;

	if (opt_fill) {
	    action("filling");

	    switch (opt_ds) {
	    case DS_8:
		if (opt_lfsr)
		    lfsr_u8(mem_ptr, mem_size, num_fill & 0xFF);
		else
		    fill_u8(mem_ptr, mem_size, num_fill & 0xFF);
		break;

	    case DS_16:
		if (opt_lfsr)
		    lfsr_u16(mem_ptr, mem_size/2, num_fill & 0xFFFF);
		else
		    fill_u16(mem_ptr, mem_size/2, num_fill & 0xFFFF);
		break;

	    case DS_32:
		if (opt_lfsr)
		    lfsr_u32(mem_ptr, mem_size/4, num_fill & 0xFFFFFFFF);
		else
		    fill_u32(mem_ptr, mem_size/4, num_fill & 0xFFFFFFFF);
		break;

	    case DS_64:
		if (opt_lfsr)
		    lfsr_u64(mem_ptr, mem_size/8, num_fill);
		else
		    fill_u64(mem_ptr, mem_size/8, num_fill);
		break;

	    default:
		exit(5);
	    }

	} else if (opt_write) {
	    ssize_t cnt = mem_size;
	    void *ptr = mem_ptr;

	    action("writing");

	    while (cnt > 0) {
		ssize_t len = read(0, ptr, cnt);

		if (len == -1) {
		    fprintf(stderr,
			"error reading from stdin.\n%s\n",
			strerror(errno));
		    exit(4);
		}
		cnt -= len;
		ptr += len;
	    }
	}

	if (opt_check) {
	    uint32_t cnt = 0;

	    action("checking");

	    switch (opt_ds) {
	    case DS_8:
		if (opt_lfsr)
		    cnt = clfsr_u8(mem_ptr, mem_size,
			num_fill & 0xFF);
		else
		    cnt = check_u8(mem_ptr, mem_size,
			num_fill & 0xFF);
		break;

	    case DS_16:
		if (opt_lfsr)
		    cnt = clfsr_u16(mem_ptr, mem_size/2,
			num_fill & 0xFFFF);
		else
		    cnt = check_u16(mem_ptr, mem_size/2,
			num_fill & 0xFFFF);
		break;

	    case DS_32:
		if (opt_lfsr)
		    cnt = clfsr_u32(mem_ptr, mem_size/4,
			num_fill & 0xFFFFFFFF);
		else
		    cnt = check_u32(mem_ptr, mem_size/4,
			num_fill & 0xFFFFFFFF);
		break;

	    case DS_64:
		if (opt_lfsr)
		    cnt = clfsr_u64(mem_ptr, mem_size/8,
			num_fill);
		else
		    cnt = check_u64(mem_ptr, mem_size/8,
			num_fill);
		break;

	    default:
		exit(5);
	    }

	    if (cnt) {
		uint32_t offs = mem_size - (cnt * opt_ds / 8);
		uint32_t addr = mem_addr + offs;

		fprintf(stderr,
		    "mismatch @0x%08X offset 0x%08X.\n",
		    addr, offs);
		exit(7);
	    }

	} else if (opt_dump) {
	    ssize_t cnt = mem_size;
	    void *ptr = mem_ptr;
	    int col = 0;

	    action("dumping");

	    while (cnt > 0) {
		char end = (col == (num_cols - 1)) ? '\n' : ' ';

		if (col == 0)
		    printf("%08X: ", mem_addr + (ptr - mem_ptr));

		switch (opt_ds) {
		case DS_8:
		    printf("%02X%c", *(uint8_t *)ptr, end);
		    ptr += 1;
		    cnt -= 1;
		    break;

		case DS_16:
		    printf("%04X%c", *(uint16_t *)ptr, end);
		    ptr += 2;
		    cnt -= 2;
		    break;

		case DS_32:
		    printf("%08X%c", *(uint32_t *)ptr, end);
		    ptr += 4;
		    cnt -= 4;
		    break;

		case DS_64:
		    printf("%016llX%c", *(uint64_t *)ptr, end);
		    ptr += 8;
		    cnt -= 8;
		    break;

		default:
		    exit(5);
		}

		col = (col + 1) % num_cols;
	    }
	    if (col)
		printf("\n");

	} else if (opt_read) {
	    ssize_t cnt = mem_size;
	    void *ptr = mem_ptr;

	    action("reading");

	    while (cnt > 0) {
		ssize_t len = write(1, ptr, cnt);

		if (len == -1) {
		    fprintf(stderr,
			"error writing to stdout.\n%s\n",
			strerror(errno));
		    exit(6);
		}
		cnt -= len;
	    }
	}

	goto rexit;

rmode:
	if (opt_wreg) {
		switch (opt_ds) {
		case DS_8:
		    *(uint8_t *)mem_ptr = num_wdat & 0xFF;
		    break;

		case DS_16:
		    *(uint16_t *)mem_ptr = num_wdat & 0xFFFF;
		    break;

		case DS_32:
		    *(uint32_t *)mem_ptr = num_wdat & 0xFFFFFFFF;
		    break;

		case DS_64:
		    *(uint64_t *)mem_ptr = num_wdat;
		    break;

		default:
		    exit(5);
		}
	}

	if (opt_rreg) {
	    switch (opt_ds) {
	    case DS_8:
	        printf("0x%02X\n", *(uint8_t *)mem_ptr);
	        break;

	    case DS_16:
	        printf("0x%04X\n", *(uint16_t *)mem_ptr);
	        break;

	    case DS_32:
	        printf("0x%08X\n", *(uint32_t *)mem_ptr);
	        break;

	    case DS_64:
	        printf("0x%016llX\n", *(uint64_t *)mem_ptr);
	        break;

	    default:
	        exit(5);
	    }
	}

rexit:
	munmap(map_ptr, map_size);
	exit(0);
}

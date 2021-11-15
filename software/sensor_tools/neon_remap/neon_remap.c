/**********************************************************************
**  neon_remap.c
**      Convert Capture Buffer to RAW Data and vice-versa
**      Version 0.1
**
**  Copyright (C) 2020 H.Poetzl
**
**      This program is free software: you can redistribute it and/or
**      modify it under the terms of the GNU General Public License
**      as published by the Free Software Foundation, either version
**      2 of the License, or (at your option) any later version.
**
**********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>


#define VERSION "V0.2"

static char *cmd_name = NULL;

static bool opt_rev = false;
static bool opt_swap = false;


static inline void __attribute__((optimize("-O3"))) __attribute__((section(".neon_asm")))
split_dline_12_neon(uint64_t *src, uint32_t cnt, uint8_t *dab, uint8_t *dcd)
{
	const uint8_t ix[2*3*8] = { 
	     7,  6,  5, 15, 14, 13, 23, 22,
	     5, 15, 14, 13, 23, 22, 21, 31,
	     6,  5, 15, 14, 13, 23, 22, 21,
	     4,  3,  2, 12, 11, 10, 20, 19,
	     2, 12, 11, 10, 20, 19, 18, 28,
	     3,  2, 12, 11, 10, 20, 19, 18,
	};

	asm volatile (
	    "vld1.8 {d16-d18}, [%[ix]]!  \n\t"	// load table transform
	    "vld1.8 {d19-d21}, [%[ix]]   \n\t"	// load table transform

	    "0:                          \n\t"	
	    "vld1.8 {d0-d2}, [%[src]]!   \n\t"	// load 3 source words

	    "vtbl.8 d10, {d0-d2}, d16    \n\t"	// split/copy A/B 0-2
	    "vtbl.8 d13, {d0-d2}, d19    \n\t"	// split/copy C/D 0-2

	    "vst1.8 {d10}, [%[dab]]!     \n\t"	// write first A/B word
	    "vst1.8 {d13}, [%[dcd]]!     \n\t"	// write first C/D word

	    "vld1.8 {d3-d5}, [%[src]]!   \n\t"	// load 3 more words

	    "vtbl.8 d11, {d2-d5}, d17    \n\t"	// split/copy A/B 2-5
	    "vtbl.8 d14, {d2-d5}, d20    \n\t"	// split/copy C/D 2-5

	    "vst1.8 {d11}, [%[dab]]!     \n\t"	// write second A/B word
	    "vst1.8 {d14}, [%[dcd]]!     \n\t"	// write second C/D word

	    "vld1.8 {d6-d7}, [%[src]]!   \n\t"	// load 2 final words

	    "vtbl.8 d12, {d5-d7}, d18    \n\t"	// split/copy A/B 5-7
	    "vtbl.8 d15, {d5-d7}, d21    \n\t"	// split/copy C/D 5-7

	    "vst1.8 {d12}, [%[dab]]!     \n\t"	// write final A/B word
	    "vst1.8 {d15}, [%[dcd]]!     \n\t"	// write final C/D word

	    "subs %[cnt], %[cnt], #1     \n\t"	// decrement loop counter
	    "bne 0b                      \n\t"	// loop if not zero

	    : [src] "+r" (src), [dab] "+r" (dab), [dcd] "+r" (dcd)

	    : [ix] "r" (ix), [cnt] "r" (cnt)

	    : "d0", "d1", "d2", "d3", 
	      "d4", "d5", "d6", "d7",
	      "d10", "d11", "d12",
	      "d13", "d14", "d15",
	      "d16", "d17", "d18",
	      "d19", "d20", "d21",
	      "cc", "memory" 
	    );
}

static inline void __attribute__((optimize("-O3"))) __attribute__((section(".neon_asm")))
combine_dline_12_neon(uint64_t *dst, uint32_t cnt, uint8_t *sab, uint8_t *scd)
{
	const uint8_t ix[2*4*8] = { 
	    ~0, ~0, 10,  9,  8,  2,  1,  0,
	    ~0, ~0, 13, 12, 11,  5,  4,  3,
	    ~0, ~0, 24, 15, 14, 16,  7,  6,
	    ~0, ~0, 11, 10,  9,  3,  2,  1,
	    ~0, ~0, 14, 13, 12,  6,  5,  4,
	    ~0, ~0, 25, 24, 15, 17, 16,  7,
	    ~0, ~0, 12, 11, 10,  4,  3,  2,
	    ~0, ~0, 15, 14, 13,  7,  6,  5,
	};

	asm volatile (
	    "vld1.8 {d16-d19}, [%[ix]]!  \n\t"	// load table transform
	    "vld1.8 {d20-d23}, [%[ix]]   \n\t"	// load table transform

	    "0:                          \n\t"	
	    "vld1.8 {d0}, [%[sab]]!      \n\t"	// load A/B word 0
	    "vld1.8 {d1}, [%[scd]]!      \n\t"	// load C/D word 0

	    "vtbl.8 d6, {d0-d1), d16     \n\t"	// assemble A/B/C/D 0-1
	    "vtbl.8 d7, {d0-d1}, d17     \n\t"	// assemble A/B/C/D 2-3

	    "vld1.8 {d2}, [%[sab]]!      \n\t"	// load A/B word 1
	    "vld1.8 {d3}, [%[scd]]!      \n\t"	// load C/D word 1

	    "vtbl.8 d8, {d0-d3}, d18     \n\t"	// assemble A/B/C/D 4-5
	    "vtbl.8 d9, {d2-d3}, d19     \n\t"	// assemble A/B/C/D 6-7

	    "vld1.8 {d4}, [%[sab]]!      \n\t"	// load A/B word 2
	    "vld1.8 {d5}, [%[scd]]!      \n\t"	// load C/D word 2

	    "vst1.8 {d6-d9}, [%[dst]]!   \n\t"	// write 4 assembled words

	    "vtbl.8 d10, {d2-d3), d20    \n\t"	// assemble A/B/C/D 8-9
	    "vtbl.8 d11, {d2-d5}, d21    \n\t"	// assemble A/B/C/D 10-11

	    "vtbl.8 d12, {d4-d5}, d22    \n\t"	// assemble A/B/C/D 12-13
	    "vtbl.8 d13, {d4-d5}, d23    \n\t"	// assemble A/B/C/D 14-15

	    "vst1.8 {d10-d13}, [%[dst]]! \n\t"	// write 4 assembled words

	    "subs %[cnt], %[cnt], #1     \n\t"	// decrement loop counter
	    "bne 0b                      \n\t"	// loop if not zero

	    : [dst] "+r" (dst), [sab] "+r" (sab), [scd] "+r" (scd)

	    : [ix] "r" (ix), [cnt] "r" (cnt)

	    : "d0", "d1", "d2", "d3", "d4", "d5",
	      "d6", "d7", "d8", "d9",
	      "d10", "d11", "d12", "d13",
	      "d16", "d17", "d18", "d19",
	      "d20", "d21", "d22", "d23",
	      "cc", "memory" 
	    );
}


#define	OPTIONS	"hrs"

int     main(int argc, char *argv[])
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
		    "-r        reverse map (raw to buffer)\n"
		    "-s        swap even and odd lines\n"
		    , cmd_name);
		exit(0);
		break;
	    case 'r':
		opt_rev = true;
		break;
	    case 's':
		opt_swap = true;
		break;
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

        void *ibuf = calloc(2048, sizeof(uint64_t));
        if (ibuf == (void *)-1) {
            fprintf(stderr,
                "error allocating memory\n%s\n",
                strerror(errno));
            exit(3);
        }

        void *obuf = calloc(2048, sizeof(uint64_t));
        if (obuf == (void *)-1) {
            fprintf(stderr,
                "error allocating memory\n%s\n",
                strerror(errno));
            exit(3);
        }

	size_t isize, offs, osize;

	if (opt_rev) {
	    isize = 8192*12/8;
	    osize = 2048*64/8;
	    offs = isize/2;
	} else {
	    isize = 2048*64/8;
	    osize = 8192*12/8;
	    offs = osize/2;
	}

	while (!feof(stdin)) {
	    size_t ilen = isize;
	    void *ptr = ibuf;

	    while (ilen) {
		size_t icnt = fread(ptr, 1, ilen, stdin);
		if (icnt > 0) {
		    ilen -= icnt;
		    ptr += icnt;
		} else if (icnt == 0) {
		    exit(0);
		} else {
		    fprintf(stderr,
			"error reading\n%s\n",
			strerror(errno));
		    exit(4);
		}
	    }

	    void *pab, *pcd;

	    if (opt_rev) {
		if (opt_swap) {
		    pab = ibuf + offs;
		    pcd = ibuf;
		} else {
		    pab = ibuf;
		    pcd = ibuf + offs;
		}

		combine_dline_12_neon(obuf, 256, pab, pcd);
	    } else {
		if (opt_swap) {
		    pab = obuf + offs;
		    pcd = obuf;
		} else {
		    pab = obuf;
		    pcd = obuf + offs;
		}

		split_dline_12_neon(ibuf, 256, pab, pcd);
	    }

	    size_t ocnt = fwrite(obuf, 1, osize, stdout);

	    if (ocnt != osize) {
		fprintf(stderr,
		    "wrote %zu bytes\n", ocnt);
		fprintf(stderr,
		    "error writing\n%s\n",
		    strerror(errno));
		exit(5);
	    }
	}

        exit(0);
}


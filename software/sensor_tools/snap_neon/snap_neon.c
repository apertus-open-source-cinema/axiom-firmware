/**********************************************************************
**  snap_cpu.c
**      Control Image Capture and Data Dump
**      Version 1.11
**
**  Copyright (C) 2013-2020 H.Poetzl
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

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>


#define VERSION "V1.11"

static uint32_t map_base = 0x18000000;
static uint32_t map_size = 0x08000000;

static uint32_t map_addr = 0x00000000;

static char *dev_mem = "/dev/mem";


static inline void __attribute__((optimize("-O3,-funroll-loops"))) __attribute__ ((section(".dump_asm")))
split_dline_12(uint64_t *ptr, unsigned count, uint8_t * outA, uint8_t * outB)
{
    for (int c = 0; c < count; c++)
    {
        uint64_t x = ptr[c];
        uint32_t a = x >> 16;  /* & 0xFFFFFF */
        uint32_t b = x >> 40;  /* & 0xFFFFFF */
        outA[c*3  ] = a >> 16; outB[c*3  ] = b >> 16;
        outA[c*3+1] = a >>  8; outB[c*3+1] = b >>  8;
        outA[c*3+2] = a      ; outB[c*3+2] = b      ;
    }
}

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
	    "vld1.8 {d0-d3}, [%[src]]!   \n\t"	// load 4 source words

	    "vtbl.8 d10, {d0-d2}, d16    \n\t"	// split/copy A/B 0-2
	    "vtbl.8 d13, {d0-d2}, d19    \n\t"	// split/copy C/D 0-2

	    "vld1.8 {d4-d7}, [%[src]]!   \n\t"	// load 4 more words

	    "vtbl.8 d11, {d2-d5}, d17    \n\t"	// split/copy A/B 2-5
	    "vtbl.8 d12, {d5-d7}, d18    \n\t"	// split/copy A/B 5-7

	    "vst1.8 {d10-d12}, [%[dab]]! \n\t"	// write 3 A/B words

	    "vtbl.8 d14, {d2-d5}, d20    \n\t"	// split/copy C/D 2-5
	    "vtbl.8 d15, {d5-d7}, d21    \n\t"	// split/copy C/D 5-7

	    "vst1.8 {d13-d15}, [%[dcd]]! \n\t"	// write 3 C/D words

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

static
double write_dline(uint64_t *ptr, unsigned count)
{
    /* allocate two line buffers on first use */
    static uint8_t * out_lines = 0;
    size_t line_size = count * 2 * 12 / 8;
    clock_t start, end;

    if (!out_lines)
    {
        out_lines = malloc(2 * line_size);

        if (!out_lines)
        {
            fprintf(stderr,
                "error allocating memory\n%s\n",
                strerror(errno));
            exit(3);
        }
    }

    /* split Bayer data in two lines for raw12 output */
    // split_dline_12(ptr, count, out_lines, out_lines + line_size);

    start = clock();
    split_dline_12_neon(ptr, count/8, out_lines + line_size, out_lines);
    end = clock();

    /* write the two lines */
    fwrite(out_lines, 1, 2 * line_size, stdout);
    return ((double)(end - start))/CLOCKS_PER_SEC;
}


int     main(int argc, char *argv[])
{
        int fd = open(dev_mem, O_RDWR | O_SYNC);
        if (fd == -1) {
            fprintf(stderr,
                "error opening >%s<.\n%s\n",
                dev_mem, strerror(errno));
            exit(1);
        }

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


        uint64_t *dp = (uint64_t *)map_addr;
	double total = 0;

        fprintf(stderr, "writing image data ...\n");

	for (int row = 0; row < 3072; row+=2) {
	    total += write_dline(dp, 32*128*2/4);
	    dp += 32*128*2/4;
	}

	fprintf(stderr, "conversion time %.3fs\n", total);

        exit(0);
}


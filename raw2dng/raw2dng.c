/*
 * Copyright (C) 2013 Magic Lantern Team
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 */

#include "stdint.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "math.h"
#include "raw.h"
#include "chdk-dng.h"

struct raw_info raw_info;

#define FAIL(fmt,...) { fprintf(stderr, "Error: "); fprintf(stderr, fmt, ## __VA_ARGS__); fprintf(stderr, "\n"); exit(1); }
#define CHECK(ok, fmt,...) { if (!ok) FAIL(fmt, ## __VA_ARGS__); }

void raw_set_geometry(int width, int height, int skip_left, int skip_right, int skip_top, int skip_bottom)
{
    raw_info.width = width;
    raw_info.height = height;
    raw_info.pitch = raw_info.width * raw_info.bits_per_pixel / 8;
    raw_info.frame_size = raw_info.height * raw_info.pitch;
    raw_info.active_area.x1 = skip_left;
    raw_info.active_area.y1 = skip_top;
    raw_info.active_area.x2 = raw_info.width - skip_right;
    raw_info.active_area.y2 = raw_info.height - skip_bottom;
    raw_info.jpeg.x = 0;
    raw_info.jpeg.y = 0;
    raw_info.jpeg.width = raw_info.width - skip_left - skip_right;
    raw_info.jpeg.height = raw_info.height - skip_top - skip_bottom;
}

//~ { "Nikon D5100", 0, 0x3de6,
//~ { 8198,-2239,-724,-4871,12389,2798,-1043,2050,7181 } },
#define CAM_COLORMATRIX1                       \
     8198, 10000,    -2239, 10000,    -724, 10000, \
    -4871, 10000,    12389, 10000,    2798, 10000, \
    -1043, 10000,     2050, 10000,    7181, 10000

struct raw_info raw_info = {
    .api_version = 1,
    .bits_per_pixel = 12,
    .black_level = 0,
    .white_level = 4096,

    // The sensor bayer patterns are:
    //  0x02010100  0x01000201  0x01020001  0x00010102
    //      R G         G B         G R         B G
    //      G B         R G         B G         G R
    .cfa_pattern = 0x02010100,

    .calibration_illuminant1 = 1,       // Daylight
    .color_matrix1 = {CAM_COLORMATRIX1},// camera-specific, from dcraw.c
};

int main(int argc, char** argv)
{
    if (argc != 2 && argc != 4)
    {
        printf("DNG converter for Apertus .raw12 files\n");
        printf("Usage:\n");
        printf("  %s input.raw12\n", argv[0]);
        printf("  %s input.raw12 <black_level> <white_level>\n", argv[0]);
        return;
    }

    FILE* fi = fopen(argv[1], "rb");
    CHECK(fi, "could not open %s", argv[1]);
    
    /* there are 4096 columns in a .raw12 file, but the number of lines is variable */
    /* autodetect it from file size, for now */
    int width = 4096;
    fseek(fi, 0, SEEK_END);
    int height = ftell(fi) / (width * 12 / 8);
    fseek(fi, 0, SEEK_SET);
    raw_set_geometry(width, height, 0, 0, 0, 0);
    
    /* use black and white levels from command-line */
    if (argc == 4)
    {
        raw_info.black_level = atoi(argv[2]);
        raw_info.white_level = atoi(argv[3]);
    }
    
    /* print current settings */
    printf("Resolution  : %d x %d\n", raw_info.width, raw_info.height);
    printf("Frame size  : %d bytes\n", raw_info.frame_size);
    printf("Black level : %d\n", raw_info.black_level);
    printf("White level : %d\n", raw_info.white_level);
    switch(raw_info.cfa_pattern) {
        case 0x02010100:
    	    printf("Bayer Order : RGGB \n");    
            break;
        case 0x01000201:
    	    printf("Bayer Order : GBRG \n");    
            break;
        case 0x01020001:
    	    printf("Bayer Order : GRBG \n");    
            break;
        case 0x00010102:
    	    printf("Bayer Order : BGGR \n");    
            break;
    }


    /* load the raw data and convert it to DNG */
    char* raw = malloc(raw_info.frame_size);
    CHECK(raw, "malloc");
    
    int r = fread(raw, 1, raw_info.frame_size, fi);
    CHECK(r == raw_info.frame_size, "fread");
    raw_info.buffer = raw;

    reverse_bytes_order(raw, raw_info.frame_size);
    
    /* replace input file extension with .DNG */
    char fo[256];
    snprintf(fo, sizeof(fo), "%s", argv[1]);
    char* ext = strchr(fo, '.');
    if (!ext) ext = fo + strlen(fo) - 4;
    ext[0] = '.';
    ext[1] = 'D';
    ext[2] = 'N';
    ext[3] = 'G';
    ext[4] = '\0';
    
    /* save the DNG */
    printf("Output file : %s\n", fo);
    save_dng(fo, &raw_info);
    fclose(fi);
    printf("Done.\n");
    return 0;
}

int raw_get_pixel(int x, int y)
{
    /* fixme: return valid values here to create a thumbnail */
    return 0;
}
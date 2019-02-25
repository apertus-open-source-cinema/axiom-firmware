/**********************************************************************
**  snap.c
**      Control Image Capture and Data Dump
**      Version 1.11
**
**  Copyright (C) 2013-2015 H.Poetzl
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
#include <semaphore.h>

#include "cmv_reg.h"
#include "scn_reg.h"

#define VERSION "cmv_snap3 V1.11"

static char *cmd_name = NULL;

static uint32_t cmv_base = 0x60000000;
static uint32_t cmv_size = 0x00400000;

static uint32_t scn_base = 0x80000000;
static uint32_t scn_size = 0x00400000;

static uint32_t map_base = 0x18000000;
static uint32_t map_size = 0x08000000;

static uint32_t map_addr = 0x00000000;

static uint32_t buf_base[4] = { -1, -1, -1, -1 };
static uint32_t buf_epat[4] = { -1, -1, -1, -1 };


static char *dev_mem = "/dev/mem";

static char *cmv_file = NULL;

static uint32_t pattern = 0xA95;

static double etime_ns[3] = { -1, -1, -1 };
static double evolt_pc[3] = { -1, -1 };

static uint32_t exp_time[3] = { 0x0, 0x0, 0x0 };
static uint16_t vtfl[3] = { 0x0, 0x0 };

static uint16_t num_frames = 1;
// static uint32_t num_switch = 1;
static uint32_t num_strobe = 0xFC;
static uint16_t num_rows = 3072;
static uint16_t num_times = 0;
static uint16_t num_volts = 0;

static int32_t out_lsl = 4;
static bool out_12 = false;
static bool out_16 = true;
static bool out_buf = false;

// static bool opt_bcols = false;
static bool opt_tpat = false;
static bool opt_dumpr = false;
static bool opt_prime = false;
static bool opt_zero = false;

static uint16_t reg82;
// static uint16_t reg83;
// static uint16_t reg84;
static uint16_t reg85;
// static uint16_t reg86;


double lvds = 250e6;
double bits = 12;
double channels = 32;

#define CLOCK_ID        CLOCK_REALTIME

#define XLINE_EO2
// #define      XLINE_EO16

#define min(a, b)       (((a) < (b)) ? (a) : (b))
#define max(a, b)       (((a) > (b)) ? (a) : (b))


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
            inv = 1;    /* invert */
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
void    split_line(uint64_t *data, uint16_t *line, uint32_t count)
{
        uint32_t bcnt = 0;
        uint64_t val = 0;

        for (int i=0; i<count ; i++) {
            if (bcnt < 12) {
                uint64_t new = *data++;
                val |= new << bcnt;
                *line++ = val & 0xFFF;
                val = new >> (12 - bcnt);
                bcnt += (64 - 12);
            } else {
                *line++ = val & 0xFFF;
                val >>= 12;
                bcnt -= 12;
            }
        }
}



static inline
void    write_value(uint16_t val)
{
        val = (val & 0xFFF) << out_lsl;

        if (out_16)
            putchar(val & 0xFF);
        putchar(val >> 8);
}

static inline
void    write_dvalue(uint32_t val)
{
        uint16_t val0 = (val & 0xFFF) << out_lsl;
        uint16_t val1 = ((val >> 12) & 0xFFF) << out_lsl;

        val = (val0 & 0xFFF) | ((val1 & 0xFFF) << 12);

        putchar((val >> 16) & 0xFF);
        putchar((val >> 8) & 0xFF);
        putchar(val & 0xFF);
}

inline void __attribute__((optimize("-O3,-funroll-loops"))) __attribute__ ((section(".dump_asm")))
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

static
void   write_dline(uint64_t *ptr, unsigned count)
{
    if (out_12)
    {
        /* allocate two line buffers on first use */
        static uint8_t * out_lines = 0;
        size_t line_size = count * 2 * 12 / 8;

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
        split_dline_12(ptr, count, out_lines, out_lines + line_size);

        /* write the two lines */
        fwrite(out_lines, 1, 2 * line_size, stdout);
    }
    else
    {
        for (int c=0; c<count; c++)
        {
            write_value((ptr[c] >> 28) & 0xFFF);
            write_value((ptr[c] >> 16) & 0xFFF);
        }
        for (int c=0; c<count; c++)
        {
            write_value((ptr[c] >> 52) & 0xFFF);
            write_value((ptr[c] >> 40) & 0xFFF);
        }
    }
}

static inline
void    write_iline(uint16_t *a, uint16_t *b,
        unsigned channels, unsigned pixels)
{
        for (int c=0; c<channels; c++) {
            for (int i=0; i<pixels; i++)
                write_value(a[i * channels + c]);
            for (int i=0; i<pixels; i++)
                write_value(b[i * channels + c]);
        }
}


static inline
void    write_register(uint16_t reg)
{
        putchar(reg & 0xFF);
        putchar(reg >> 8);
}

static inline
uint16_t read_register(int fd)
{
        uint8_t rl, rh;

        read(fd, &rl, 1);
        read(fd, &rh, 1);
        return rh << 8 | rl;
}


static inline
double  ns_to_us(double val)
{
        return val * 1e-3;
}

static inline
double  ns_to_ms(double val)
{
        return val * 1e-6;
}

static inline
double  ns_to_s(double val)
{
        return val * 1e-9;
}


static inline
double  s_to_ns(double val)
{
        return val * 1e9;
}

static inline
double  ms_to_ns(double val)
{
        return val * 1e6;
}

static inline
double  us_to_ns(double val)
{
        return val * 1e3;
}


static inline
double  len_to_ns(uint32_t len)
{
        return len * (bits/lvds) * 1e9 / channels;
}

static inline
double  len_to_us(uint32_t len)
{
        return ns_to_us(len_to_ns(len));
}

static inline
double  len_to_ms(uint32_t len)
{
        return ns_to_ms(len_to_ns(len));
}


static inline
double  delta_ns(struct timespec *a, struct timespec *b)
{
        double delta = b->tv_nsec - a->tv_nsec;

        return delta + (b->tv_sec - a->tv_sec) * 1e9;
}

static inline
double  delta_us(struct timespec *a, struct timespec *b)
{
        return ns_to_us(delta_ns(a, b));
}

static inline
double  delta_ms(struct timespec *a, struct timespec *b)
{
        return ns_to_ms(delta_ns(a, b));
}


static inline
double  read_out(uint32_t frames)
{
        return len_to_ns(num_rows * 4096 * frames);
}

static inline
double  exposure(uint32_t time)
{
        double fot_overlap = 34 * (reg82 & 0xFF) + 1;

        return ((time - 1)*(reg85 + 1) + fot_overlap) *
                (bits/lvds) * 1e9;
}

static inline
double  fot(uint32_t time)
{
        double val = ((reg82 >> 8) + 2)*(reg85 + 1);

        return val * (bits/lvds) * 1e9;
}

static inline
double  total(uint32_t time, uint32_t frames)
{
        double val = (time - 1)*(reg85 + 1) * (bits/lvds) * 1e9;
        
        val += fot(time);
        val += read_out(frames);        /* on the safe side */
        val *= frames;

        return val;
}



/*      [71/72] exposure time
        [82]    FOT timing
        [83]    sample timing
        [84]    adc timing
        [85]    slot timing
        [86]    sub slot timing
        
        (a - 1)*(b + 1) + c = d         */

uint32_t calc_exp_time(double etime_ns)
{
        double lvds = 250e6;
        double bits = 12;
        double fot_overlap = 34 * (reg82 & 0xFF) + 1;

        double d = etime_ns * (lvds/bits) * 1e-9;
        double val;

        if (fot_overlap < d) {
            val = (d - fot_overlap)/(reg85 + 1) + 1;
        } else {
            val = 1;
        }
        return val;
}


void    out_time(FILE *stream, const char *label, double ns)
{
        fprintf(stream, "%8s : %9.3fus\n", label, ns_to_us(ns));
}

char *  parse_etime(const char *ptr, double *etime)
{
        char *sep = NULL;
        double val = 0;

        val = strtod(ptr, &sep);
        if (sep[0]) {
            if (strncmp(sep, "s", 1) == 0) {
                *etime = s_to_ns(val);
                return &sep[1];
            } else if (strncmp(sep, "ms", 2) == 0) {
                *etime = ms_to_ns(val);
                return &sep[2];
            } else if (strncmp(sep, "us", 2) == 0) {
                *etime = us_to_ns(val);
                return &sep[2];
            } else if (strncmp(sep, "ns", 2) == 0) {
                *etime = val;
                return &sep[2];
            }
        }
        return sep;
}

int     parse_etimes(const char *ptr, double *etime)
{
        char *sep = NULL;
        unsigned cnt = 1;

        sep = parse_etime(ptr, &etime[0]);
        if (sep[0] == ',') {
            sep = parse_etime(&sep[1], &etime[1]);
            cnt++;
        }
        if (sep[0] == ',') {
            sep = parse_etime(&sep[1], &etime[2]);
            cnt++;
        }
        return cnt;
}


char *  parse_evolt(const char *ptr, double *evolt)
{
        char *sep = NULL;

        *evolt = strtod(ptr, &sep);
        return sep;
}

int     parse_evolts(const char *ptr, double *evolt)
{
        char *sep = NULL;
        unsigned cnt = 1;

        sep = parse_evolt(ptr, &evolt[0]);
        if (sep[0] == ',') {
            sep = parse_evolt(&sep[1], &evolt[1]);
            cnt++;
        }
        return cnt;
}



void    status(const char *str)
{
        uint32_t val = get_fil_reg(FIL_REG_STATUS);
        
        fprintf(stderr, "%s:\n", str);
        fprintf(stderr, "\twriter:\t%s\n",
            val & 0x01000000 ? "inactive" : "active");
        fprintf(stderr, "\tfifo:\terr = %d/%d\tlvl = %d/%d/%d/%d\n",
            val & 0x00200000 ? 1 : 0,
            val & 0x00100000 ? 1 : 0,
            val & 0x00080000 ? 1 : 0,
            val & 0x00040000 ? 1 : 0,
            val & 0x00020000 ? 1 : 0,
            val & 0x00010000 ? 1 : 0);
}

static uint16_t cmv_regs[128];

static void get_cmv_metadata()
{
    for (int i=0; i<128; i++)
    {
        cmv_regs[i] = get_cmv_reg(i);
    }
}

static void write_cmv_metadata()
{
    fwrite(cmv_regs, 2, 128, stdout);
}

static sem_t * cmv_sem = 0;
static char cmv_sem_name[]= "cmv";

static void cmv_sem_unlock_and_cleanup()
{
    if (cmv_sem)
    {
        /* note: we must call sem_post exactly once */
        /* otherwise, we will allow two other snap processes
         * running at the same time (and locking up the system)
         */
        sem_post(cmv_sem);
        sem_close(cmv_sem);
        sem_unlink(cmv_sem_name);
        cmv_sem = 0;
    }
}

/* caveat: this can be called only once at startup */
static void cmv_sem_init_and_lock()
{
    cmv_sem = sem_open(cmv_sem_name,O_CREAT,0644,1);
    if (cmv_sem == SEM_FAILED)
    {
        perror("unable to create semaphore");
        exit(-1);
    }

    sem_wait(cmv_sem);
    if (cmv_sem == SEM_FAILED)
    {
        perror("unable to lock semaphore");
        exit(-1);
    }

    /* unlock and delete the semaphore, no matter how we exit */
    atexit(cmv_sem_unlock_and_cleanup);
}

#define OPTIONS "h82dbprtze:v:s:S:P:R:"

int     main(int argc, char *argv[])
{
        extern int optind;
        extern char *optarg;
        int c, err_flag = 0;

        /* need exclusive access to image capture hardware */
        /* useful if we want to start multiple copies of snap.c in parallel */
        cmv_sem_init_and_lock();

        cmd_name = argv[0];
        while ((c = getopt(argc, argv, OPTIONS)) != EOF) {
            switch (c) {
            case 'h':
                fprintf(stderr,
                    "This is %s " VERSION "\n"
                    "options are:\n"
                    "-h        print this help message\n"
                    "-8        output 8 bit per pixel\n"
                    "-2        output 12 bit per pixel\n"
                    "-d        dump buffer memory\n"
                    "-b        enable black columns\n"
                    "-p        prime buffer memory\n"
                    "-r        dump sensor registers\n"
                    "-t        enable cmv test pattern\n"
                    "-z        produce no data output\n"
        //          "-n <num>  number of frames\n"
                    "-e <exp>  exposure times\n"
                    "-v <exp>  exposure voltages\n"
                    "-s <num>  shift values by <num>\n"
        //          "-N <num>  number of switches\n"
                    "-S <val>  writer byte strobe\n"
        //          "-M <val>  buffer memory bases\n"
        //          "-Z <val>  buffer memory sizes\n"
                    "-R <fil>  load sensor registers\n"
                    , cmd_name);
                exit(0);
                break;
            case '2':
                out_12 = true;
                out_lsl = 0;
                break;
            case '8':
                out_16 = false;
                break;
            case 'd':
                out_buf = true;
                break;
            case 'b':
                // opt_bcols = true;
                break;
            case 'p':
                opt_prime = true;
                break;
            case 'r':
                opt_dumpr = true;
                break;
            case 't':
                opt_tpat = true;
                break;
            case 'z':
                opt_zero = true;
                break;
        /*  case 'n':
                num_frames = argtoll(optarg, NULL, NULL);
                break; */
            case 'e':
                num_times = parse_etimes(optarg, etime_ns);
                break;
            case 'v':
                num_volts = parse_evolts(optarg, evolt_pc);
                break;
            case 's':
                out_lsl = argtoll(optarg, NULL, NULL);
                break;
            case 'S':
                num_strobe = argtoll(optarg, NULL, NULL);
                break;
        /*  case 'N':
                num_switch = argtoll(optarg, NULL, NULL);
                break; */
        /*  case 'M':
                map_base = argtoll(optarg, NULL, NULL);
                break;
            case 'Z':
                map_size = argtoll(optarg, NULL, NULL);
                break; */
            case 'P':
                pattern = argtoll(optarg, NULL, NULL) & 0xFFF;
                break;
            case 'R':
                cmv_file = optarg;
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


        if (num_times == 0)
            goto regs;

        if (opt_prime) {
            fprintf(stderr, "priming buffer memory ...\n");

            for (int a=0; a<map_size; a+=4)
                *((uint32_t *)(buf + a)) = 0xEEEEEEEE;
        }

        // uint16_t bcols = opt_bcols ? 0x8000 : 0x0000;

        set_cmv_reg(80, num_frames);

        reg82 = get_cmv_reg(82);
        reg85 = get_cmv_reg(85);


        if (num_times > 2) {
            exp_time[2] = calc_exp_time(etime_ns[2]);
        }
        if (num_times > 1) {
            exp_time[1] = calc_exp_time(etime_ns[1]);
        }
        if (num_times > 0) {
            exp_time[0] = calc_exp_time(etime_ns[0]);

            /* configure all 3 exposure registers if -e is specified */
            set_cmv_reg(71, exp_time[0] & 0xFFFF);
            set_cmv_reg(72, exp_time[0] >> 16);
            set_cmv_reg(75, exp_time[1] & 0xFFFF);
            set_cmv_reg(76, exp_time[1] >> 16);
            set_cmv_reg(77, exp_time[2] & 0xFFFF);
            set_cmv_reg(78, exp_time[2] >> 16);
        }
        
        /* default value for Vtfl: both fields enabled, with value 0 */
        /* todo: check what happens if Vtfl is disabled */
        set_cmv_reg(106, 0x2040);

        if (num_volts > 1) {
            vtfl[1] = evolt_pc[1];
            set_cmv_reg(106,
                (get_cmv_reg(106) & ~(0x7F << 7)) |
                ((vtfl[1] << 7) & 0x7F));
        }
        if (num_volts > 0) {
            vtfl[0] = evolt_pc[0];
            set_cmv_reg(106,
                (get_cmv_reg(106) & ~0x7F) |
                (vtfl[0] & 0x7F));
        }

        set_cmv_reg(122, (get_cmv_reg(122) & ~3)
            | (opt_tpat ? 0x3 : 0x0));

        if (num_times > 0)
            set_cmv_reg(79, min(3, max(1, num_times)));

regs:
        if (cmv_file != NULL) {
            fprintf(stderr, "loading registers ...\n");

            int rfd = open(cmv_file, O_RDONLY);
            if (rfd == -1) {
                fprintf(stderr,
                    "error opening >%s<.\n%s\n",
                    cmv_file, strerror(errno));
                exit(3);
            }

            for (int i=0; i<128; i++)
                set_cmv_reg(i, read_register(rfd));

        }

        reg82 = get_cmv_reg(82);
        reg85 = get_cmv_reg(85);

        if (num_times == 0)
            goto skip;

        exp_time[0] = get_cmv_reg(72) << 16 | get_cmv_reg(71);
        exp_time[1] = get_cmv_reg(76) << 16 | get_cmv_reg(75);
        exp_time[2] = get_cmv_reg(78) << 16 | get_cmv_reg(77);

        vtfl[0] = get_cmv_reg(106) & 0x7F;
        vtfl[1] = (get_cmv_reg(106) >> 7) & 0x7F;

        num_frames = get_cmv_reg(80);

        fprintf(stderr, "exp_time = %06X/%06X/%06X\n",
            exp_time[0], exp_time[1], exp_time[2]);
        // fprintf(stderr, "num_frames = %04X\n", num_frames);
        fprintf(stderr, "vtfl = %02X/%02X\n",
            vtfl[0], vtfl[1]);

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
        uint16_t wsel = (status >> 30) & 0x3;

        /* save cmv sensor metadata to memory, to be saved at the end of the file */
        /* useful if multiple copies of snap are pipelined */
        /* so each image gets the correct metadata */
        get_cmv_metadata();

        fprintf(stderr, "triggering image capture ...\n");

// again:
        set_fil_reg(FIL_REG_OVERRIDE,   0x01000100);
        usleep(10);
        set_fil_reg(FIL_REG_OVERRIDE,   ovr);

        fprintf(stderr, "waiting for sequencer ...\n");

        while (tgl == ((cseq >> 31) & 0x1))
            cseq = get_fil_reg(FIL_REG_CSEQ);

        uint32_t addr = get_fil_reg(FIL_REG_ADDR);

        fprintf(stderr, "gen address = 0x%08lX\n",
            (unsigned long)addr);

        uint16_t rsel = (get_gen_reg(GEN_REG_STATUS) >> 30) & 0x3;

        fprintf(stderr,
            "read/write buffer = 0x%08lX/0x%08lX\n",
            (unsigned long)buf_base[rsel],
            (unsigned long)buf_base[wsel]);

        /* uint32_t ctrl = get_gen_reg(GEN_REG_CONTROL);

        set_gen_reg(GEN_REG_CONTROL, ctrl ^ 0x80);
        set_gen_reg(GEN_REG_CONTROL, ctrl);*/

        /* capture complete; other processes can now capture images
         * while we are saving the current one.
         *
         * FIXME: why do we need an extra delay here?
         * (10000 is too small, locks up the camera)
         */
        usleep(20000);
        cmv_sem_unlock_and_cleanup();

        if (opt_zero)
            goto skip;

        uint64_t *dp = (uint64_t *)(map_addr + (buf_base[wsel] - map_base));
        size_t ds = (unsigned long)addr - (unsigned long)buf_base[rsel];

        if (out_buf) {
            fprintf(stderr, "dumping buffer data ...\n");
            fprintf(stderr, "%p %d\n", dp, ds);

            while (ds > 0) {
                ssize_t cnt = write(1, dp, ds);

                fprintf(stderr, "%p %d -> %d\n", dp, ds, cnt);
                dp = (uint64_t *)(((char *)dp) + cnt);
                ds -= cnt;
            }
        } else {
            fprintf(stderr, "writing image data ...\n");

            clock_t t1,t2;
            t1 = clock();
            for (int frame = 0; frame < num_frames; frame++) {
                for (int row = 0; row < 3072; row+=2) {
                    write_dline(dp, 32*128*2/4);
                    dp += 32*128*2/4;
                }
            }
            t2 = clock() - t1;
            fprintf(stderr, "writing took %.2f s.\n", (double)t2 / CLOCKS_PER_SEC);
        }


skip:
        if (opt_dumpr)
            write_cmv_metadata();

        exit((err_flag)?1:0);
}


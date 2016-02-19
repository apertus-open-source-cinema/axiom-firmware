/**********************************************************************
**  pong.c
**	Play PONG as Overlay
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

#include <sys/timerfd.h>
#include <sys/ioctl.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>
#include <math.h>


#include "cmv_reg.h"
#include "scn_reg.h"

#define	VERSION	"V1.0"

static char *cmd_name = NULL;

static uint32_t cmv_base = 0x60000000;
static uint32_t cmv_size = 0x00800000;

static uint32_t scn_base = 0x80000000;
static uint32_t scn_size = 0x00800000;

static uint32_t map_base = 0x18000000;
static uint32_t map_size = 0x08000000;

static uint32_t map_addr = 0x00000000;

static uint16_t num_fps = 60;

// static uint16_t num_rows = 1080;


static char *dev_mem = "/dev/mem";

static char *dev_i2c = "/dev/i2c-1";


#define min(a, b)	(((a) < (b)) ? (a) : (b))
#define max(a, b)	(((a) > (b)) ? (a) : (b))

#define sgn(a)		(((a) == 0) ? 0 : (((a) < 0) ? -1 : 1))


typedef
struct _field {
    uint16_t hmin;
    uint16_t hmax;

    uint16_t vmin;
    uint16_t vmax;

    float ivec_f;
    float imul_f;

}   field_t;

typedef
struct _player {
    uint16_t hpos;
    uint16_t vpos;

    uint16_t hsize;
    uint16_t vsize;
}   player_t;

typedef
struct _ball {
    uint16_t hpos;
    uint16_t vpos;

    uint16_t hsize;
    uint16_t vsize;

    float hpos_f;
    float vpos_f;
    float hvec_f;
    float vvec_f;

    float angle_f;

    uint32_t color;
}   ball_t;

typedef
struct _score {
    uint16_t hpos;
    uint16_t vpos;

    uint32_t score;
    uint32_t mask;
    uint32_t color;
}   score_t;

typedef
struct _anim {
    int32_t cnt_reset;
    int32_t cnt_bounce;
    int32_t cnt_fade;
    int32_t cnt_lflash;
    int32_t cnt_rflash;
    
    int32_t col_bounce;
    int32_t col_fade;
    int32_t col_lflash;
    int32_t col_rflash;
}   anim_t;


typedef
struct _state {
    enum {
	S_INITIAL = 0,
	S_GAME = 1,
	S_MISSED_L,
	S_MISSED_R,
	S_NEXT_ROUND,
	S_RESET,
	S_RESTART,
	S_UNKNOWN,
    } s;

    field_t f;
    player_t l;
    score_t ls;
    player_t r;
    score_t rs;
    ball_t b;
    anim_t a;
}   state_t;


#define	CLOCK_ID	CLOCK_REALTIME

uint16_t score_num[] = {
    0x7B6F /* 0x4924 */, 0x2492, 0x73E7, 0x79E7, 0x49ED,
    0x79CF, 0x7BCF, /* 0x12A7 */ 0x4927, 0x7BEF, 0x79EF,
    0x0080, 0x0080, 0x0080, 0x0080, 0x0080,
    0x0000
};


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


uint32_t get_pon_reg(unsigned reg)
{
	volatile uint32_t *ptr = (uint32_t *)(scn_addr + 0x00700100);
	return ptr[reg];
}

void	set_pon_reg(unsigned reg, uint32_t val)
{
	volatile uint32_t *ptr = (uint32_t *)(scn_addr + 0x00700100);
	ptr[reg] = val;
}

enum _pon_reg {
	PON_REG_LHPOS = 0,
	PON_REG_LVPOS = 1,
	PON_REG_LCOLOR = 2,

	PON_REG_RHPOS = 3,
	PON_REG_RVPOS = 4,
	PON_REG_RCOLOR = 5,

	PON_REG_BHPOS = 6,
	PON_REG_BVPOS = 7,
	PON_REG_BCOLOR = 8,

	PON_REG_NHPOS = 9,
	PON_REG_NVRMD = 10,
	PON_REG_NCOLOR = 11,

	PON_REG_LSPOS = 12,
	PON_REG_LSMASK = 13,
	PON_REG_LSCOLOR = 14,

	PON_REG_RSPOS = 15,
	PON_REG_RSMASK = 16,
	PON_REG_RSCOLOR = 17,
};



static inline
float	check_hit(float a, float b, float d)
{
	return (a - b)/d;
}

static inline
bool	check_in(float v, float a, float b)
{
	return (v > a) && (v < b);
}


uint32_t color_mix(uint32_t c1, uint32_t c2, float m)
{
	uint16_t r,g1,g2,b;

	r = ((c2 >> 24) & 0xFF) * m + ((c1 >> 24) & 0xFF) * (1.0 - m);
	g1 = ((c2 >> 16) & 0xFF) * m + ((c1 >> 16) & 0xFF) * (1.0 - m);
	g2 = ((c2 >> 8) & 0xFF) * m + ((c1 >> 8) & 0xFF) * (1.0 - m);
	b = ((c2 >> 0) & 0xFF) * m + ((c1 >> 0) & 0xFF) * (1.0 - m);

	return ((r & 0xFF) << 24) | ((g1 & 0xFF) << 16) |
		((g2 & 0xFF) << 8) | ((b & 0xFF) << 0);
}


uint32_t score_mask(uint32_t score)
{
	uint16_t dig[] = { score / 10, score % 10 };
	
	return score_num[dig[0]] | (score_num[dig[1]] << 16);
}



state_t	state = {
	.s = S_INITIAL,
	.f = { .hmin = 0x31, .hmax = 0x770, .vmin = 0x41, .vmax = 0x450, 
		.ivec_f = 4.0, .imul_f = 1.0 },
	.l = { .hpos = 0x49, .vpos = 0x100, .hsize = 0x8, .vsize = 0x50 },
	.ls = { .hpos = 0x301, .vpos = 0x51, .score = 98 },
	.r = { .hpos = 0x74B, .vpos = 0x300, .hsize = 0x8, .vsize = 0x50 },
	.rs = { .hpos = 0x501, .vpos = 0x51, .score = 95 },
	.b = { .hsize = 0xC, .vsize = 0xC,
	       .hpos_f = 0x501, .vpos_f = 0x301, .hvec_f = -1.9, .vvec_f = -2.05 },
	.a = { .cnt_reset = -1 },
    };




#define	MUL_HIT		-1.02
#define	ADD_HIT		 0.1
#define MUL_BOUNCE	-1.01
#define ADD_BOUNCE	 0.1

#define	CNT_RESET	60
#define	CNT_BOUNCE	40
#define	CNT_FADE	30
#define	CNT_FLASH	30


void	animate(state_t *state, unsigned steps)
{
	while (steps-- > 0) {
	    state->b.hpos_f += state->b.hvec_f;
	    state->b.vpos_f += state->b.vvec_f;

	    switch (state->s) {
	    case S_INITIAL:
		if ((state->ls.score == 99) ||
		    (state->rs.score == 99))
		    state->s = S_RESTART;
		else
		    state->s = S_GAME;

		state->b.hpos_f = (state->f.hmin + state->f.hmax) / 2.0;
		state->b.vpos_f = (state->f.vmin + state->f.vmax) / 2.0;

		state->f.imul_f *= -1.0;

		float ang = fmod(random()/4096.0, M_PI/2) + M_PI/4;
		state->b.hvec_f = sin(ang) * state->f.ivec_f * state->f.imul_f;
		state->b.vvec_f = cos(ang) * state->f.ivec_f * state->f.imul_f;
		state->b.angle_f = ang;

		state->b.color = 0xFFFFFFFF;

		state->ls.mask = score_mask(state->ls.score);
		state->rs.mask = score_mask(state->rs.score);

		break;
	
	    case S_GAME:
		if ((state->b.hpos_f - state->b.hsize) <=
		    (state->l.hpos + state->l.hsize)) {
		    float hit = check_hit(
			state->b.vpos_f,
			state->l.vpos,
			state->l.vsize + state->b.vsize);

		    if ((hit > -1.0) && (hit < 1.0)) {
			state->b.hvec_f *= MUL_HIT;
			state->b.hvec_f += sgn(state->b.hvec_f) * ADD_HIT;

			float ang = atan2(state->b.hvec_f, state->b.vvec_f);
			float len = sqrt(state->b.hvec_f * state->b.hvec_f +
			    state->b.vvec_f * state->b.vvec_f);

			ang -= hit * M_PI/10;
			ang = min(max(M_PI/6, fabs(ang)), 5*M_PI/6)*sgn(ang);
			state->b.hvec_f = sin(ang) * len;
			state->b.vvec_f = cos(ang) * len;

			state->a.col_bounce = 0xFFFFFF00;
			state->a.cnt_bounce = CNT_BOUNCE;
		    } else
			state->s = S_MISSED_L;
		}
	
		if ((state->b.hpos_f + state->b.hsize) >=
		    (state->r.hpos - state->r.hsize)) {
		    float hit = check_hit(
			state->b.vpos_f,
			state->r.vpos,
			state->r.vsize + state->b.vsize);

		    if ((hit > -1.0) && (hit < 1.0)) {
			state->b.hvec_f *= MUL_HIT;
			state->b.hvec_f += sgn(state->b.hvec_f) * ADD_HIT;

			float ang = atan2(state->b.hvec_f, state->b.vvec_f);
			float len = sqrt(state->b.hvec_f * state->b.hvec_f +
			    state->b.vvec_f * state->b.vvec_f);

			ang += hit * M_PI/10;
			ang = min(max(M_PI/6, fabs(ang)), 5*M_PI/6)*sgn(ang);
			state->b.hvec_f = sin(ang) * len;
			state->b.vvec_f = cos(ang) * len;

			state->a.col_bounce = 0xFFFFFF00;
			state->a.cnt_bounce = 30;
		    } else
			state->s = S_MISSED_R;
		}
		break;

	    case S_MISSED_L:
		state->b.color = 0xFF000000;
		state->a.cnt_reset = CNT_RESET;
		state->a.cnt_fade = CNT_FADE;
		state->a.col_fade = 0x00000000;
		state->rs.score++;
		state->rs.mask = score_mask(state->rs.score);
		state->a.cnt_rflash = CNT_FLASH;
		state->a.col_rflash = 0xFF000000;
		state->s = S_NEXT_ROUND;
		break;

	    case S_MISSED_R:
		state->b.color = 0x000000FF;
		state->a.cnt_reset = CNT_RESET;
		state->a.cnt_fade = CNT_FADE;
		state->a.col_fade = 0x00000000;
		state->ls.score++;
		state->ls.mask = score_mask(state->ls.score);
		state->a.cnt_lflash = CNT_FLASH;
		state->a.col_lflash = 0x000000FF;
		state->s = S_NEXT_ROUND;
		break;

	    case S_UNKNOWN:
		break;

	    case S_NEXT_ROUND:

		break;

	    case S_RESTART:
		state->ls.score = 0;
		state->ls.mask = score_mask(state->ls.score);
		state->rs.score = 0;
		state->rs.mask = score_mask(state->rs.score);

		state->s = S_INITIAL;
		break;

	    default:
		if (state->b.hpos_f >= state->f.hmax)
		    state->s = S_NEXT_ROUND;

		if (state->b.hpos_f <= state->f.hmin)
		    state->s = S_NEXT_ROUND;

	    }

	    /* bounce off wall */

	    if ((state->b.vpos_f >=
		    (state->f.vmax - fabs(state->b.vvec_f))) ||
		(state->b.vpos_f <= 
		    (state->f.vmin + fabs(state->b.vvec_f)))) {
		state->b.vvec_f *= MUL_BOUNCE;
		state->b.vvec_f += sgn(state->b.vvec_f) * ADD_BOUNCE;

		state->a.col_bounce = 0x80808080;
		state->a.cnt_bounce = 30;
	    }

	    /* variable update */

	    state->b.hpos = ((int)state->b.hpos_f & ~1) + 1;
	    state->b.vpos = ((int)state->b.vpos_f);

	    /* animation timer */

	    if (state->a.cnt_reset >= 0) {
		if (state->a.cnt_reset == 0)
		    state->s = S_INITIAL;
		state->a.cnt_reset--;
	    }

	    if (state->a.cnt_bounce > 0)
		state->a.cnt_bounce--;

	    if (state->a.cnt_fade > 0)
		state->a.cnt_fade--;

	    if (state->a.cnt_lflash > 0)
		state->a.cnt_lflash--;

	    if (state->a.cnt_rflash > 0)
		state->a.cnt_rflash--;

	}
}

void	display(state_t *state)
{
	if (check_in(state->l.hpos, state->f.hmin, state->f.hmax))
	    set_pon_reg(PON_REG_LHPOS,
		((state->l.hpos + state->l.hsize) << 16) |
		(state->l.hpos - state->l.hsize));
	else
	    set_pon_reg(PON_REG_LHPOS, 0);

	if (check_in(state->l.vpos, state->f.vmin, state->f.vmax))
	    set_pon_reg(PON_REG_LVPOS,
		((state->l.vpos + state->l.vsize) << 16) |
		(state->l.vpos - state->l.vsize));
	else
	    set_pon_reg(PON_REG_LVPOS, 0);

	if (check_in(state->r.hpos, state->f.hmin, state->f.hmax))
	    set_pon_reg(PON_REG_RHPOS,
		((state->r.hpos + state->r.hsize) << 16) |
		(state->r.hpos - state->r.hsize));
	else
	    set_pon_reg(PON_REG_RHPOS, 0);

	if (check_in(state->r.vpos, state->f.vmin, state->f.vmax))
	    set_pon_reg(PON_REG_RVPOS,
		((state->r.vpos + state->r.vsize) << 16) |
		(state->r.vpos - state->r.vsize));
	else
	    set_pon_reg(PON_REG_RVPOS, 0);

	if (check_in(state->b.hpos, state->f.hmin, state->f.hmax))
	    set_pon_reg(PON_REG_BHPOS,
		((state->b.hpos + state->b.hsize) << 16) |
		(state->b.hpos - state->b.hsize));
	else
	    set_pon_reg(PON_REG_BHPOS, 0);

	if (check_in(state->b.vpos, state->f.vmin, state->f.vmax))
	    set_pon_reg(PON_REG_BVPOS,
		((state->b.vpos + state->b.vsize) << 16) |
		(state->b.vpos - state->b.vsize));
	else
	    set_pon_reg(PON_REG_BVPOS, 0);

	uint32_t bcolor = state->b.color;
	if (state->a.cnt_bounce)
	    bcolor = color_mix(bcolor,
		state->a.col_bounce,
		state->a.cnt_bounce * 1.0 / CNT_BOUNCE);
	if (state->a.cnt_fade)
	    bcolor = color_mix(state->a.col_fade,
		bcolor, state->a.cnt_fade * 1.0 / CNT_FADE);
	
	set_pon_reg(PON_REG_BCOLOR, bcolor);
	set_pon_reg(PON_REG_NCOLOR, state->b.color);

	set_pon_reg(PON_REG_LSCOLOR, color_mix(
	    0xFFFFFFFF, state->a.col_lflash,
	    state->a.cnt_lflash * 1.0 / CNT_FLASH));

	set_pon_reg(PON_REG_RSCOLOR, color_mix(
	    0xFFFFFFFF, state->a.col_rflash,
	    state->a.cnt_rflash * 1.0 / CNT_FLASH));

	set_pon_reg(PON_REG_LSMASK, state->ls.mask);
	set_pon_reg(PON_REG_RSMASK, state->rs.mask);
}


uint16_t read_paddle(int i2c, unsigned id)
{
	set_fil_reg(FIL_REG_LEDOVR, (id & 3) << 12);
	usleep(1000);
	
	uint8_t i2c_data[2] = { 0 };
	int i2c_cnt = read(i2c, &i2c_data, 2);
	if (i2c_cnt < 0) {
	    fprintf(stderr,
		"error reading from i2c.\n%s\n",
		strerror(errno));
	}
	return i2c_data[1] | (i2c_data[0] << 8);
}



#define	OPTIONS	"h"

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
		    , cmd_name);
		exit(0);
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


	int i2c = open(dev_i2c, O_RDWR | O_SYNC | O_NONBLOCK);
	if (i2c == -1) {
	    fprintf(stderr,
		"error opening >%s<.\n%s\n",
		dev_i2c, strerror(errno));
	    exit(1);
	}

	int i2c_addr = 0x4D; /* The I2C address */

	if (ioctl(i2c, I2C_SLAVE, i2c_addr) < 0) {
	    fprintf(stderr,
		"error setting slave address 0x%02x.\n%s\n",
		i2c_addr, strerror(errno));
	    exit(1);
	}

	fprintf(stderr, "paddle[1] = 0x%02X\n", read_paddle(i2c, 1));
	fprintf(stderr, "paddle[2] = 0x%02X\n", read_paddle(i2c, 2));


	int it = timerfd_create(CLOCK_REALTIME, TFD_NONBLOCK | TFD_CLOEXEC);
	if (it == -1) {
	    fprintf(stderr,
		"error creating timerfd.\n%s\n",
		strerror(errno));
	    exit(1);
	}

	set_pon_reg(PON_REG_LCOLOR, 0xFFFFFFFF);
	set_pon_reg(PON_REG_RCOLOR, 0xFFFFFFFF);
	set_pon_reg(PON_REG_BCOLOR, 0xFFFFFFFF);
	set_pon_reg(PON_REG_NCOLOR, 0xFFFFFFFF);

	set_pon_reg(PON_REG_NHPOS, 0x03D303C3);
	set_pon_reg(PON_REG_NVRMD, 0x001E000F);

	set_pon_reg(PON_REG_LSPOS, 0x00510301);
	set_pon_reg(PON_REG_RSPOS, 0x00510409);

	set_pon_reg(PON_REG_LSCOLOR, 0xFFFFFFFF);
	set_pon_reg(PON_REG_RSCOLOR, 0xFFFFFFFF);

	struct itimerspec it_spec;
	
	it_spec.it_interval = (struct timespec){ 0, 1000000000L/num_fps };
	it_spec.it_value = (struct timespec){ 0, 1 };

	timerfd_settime(it, 0, &it_spec, NULL);

	fd_set fds;

	FD_ZERO(&fds);
	FD_SET(0, &fds);
	FD_SET(it, &fds);

	float paddle[2] = { 0.5, 0.5 };

	while (1) {
	    fd_set read_set = fds;
	    /* int num = */ (void)select(it + 1, &read_set, NULL, NULL, NULL);

	    if (FD_ISSET(it, &read_set)) {
		uint64_t expired;
		/* int cnt = */ (void)read(it, &expired, sizeof(expired));

		paddle[0] = (paddle[0] * 3 + read_paddle(i2c, 1)/4096.0)/4;
		paddle[1] = (paddle[1] * 3 + read_paddle(i2c, 2)/4096.0)/4;

		state.l.vpos = paddle[0] * 884 + 140;
		state.r.vpos = paddle[1] * 884 + 140;

		animate(&state, expired);
		display(&state);

		paddle[0] = (paddle[0] * 3 + read_paddle(i2c, 1)/4096.0)/4;
		paddle[1] = (paddle[1] * 3 + read_paddle(i2c, 2)/4096.0)/4;
	    }
	    if (FD_ISSET(0, &read_set)) {
		char buf[1024];
		char cmd;
		float arg[3];

		/* int cnt = */ (void)read(0, &buf, sizeof(buf));
		int num = sscanf(buf, "%c %f %f %f", &cmd, &arg[0], &arg[1], &arg[2]);

		fprintf(stderr, "cmd[%d] = %c, %f,%f,%f\n",
		    num, cmd, arg[0], arg[1], arg[2]);
		switch (cmd) {
		case 'F':
		    state.b.hvec_f *= arg[0];
		    state.b.vvec_f *= arg[0];
		    if (num > 2)
			state.f.ivec_f = arg[1];
		    break;

		case 'R':
		    state.s = S_RESTART;
		    break;

		case 'S':
		    state.ls.score = arg[0];
		    state.ls.mask = score_mask(state.ls.score);
		    state.rs.score = arg[1];
		    state.rs.mask = score_mask(state.rs.score);
		    break;

		default:
		    break;
		}
	    }
	}

	exit((err_flag)?1:0);
}



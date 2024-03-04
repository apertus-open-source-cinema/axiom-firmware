/**********************************************************************
**  prng.c
**      Pseudo Random Number Generator
**      Version 1.2
**
**  Copyright (C) 2014-2020 H.Poetzl
**
**      This program is free software: you can redistribute it and/or
**      modify it under the terms of the GNU General Public License
**      as published by the Free Software Foundation, either version
**      2 of the License, or (at your option) any later version.
**
**********************************************************************/

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


#define BUF_SIZE 4096

static uint64_t buf[BUF_SIZE];

static inline uint64_t
xoroshiro128plus(uint64_t s[2])
{
    uint64_t s0 = s[0];
    uint64_t s1 = s[1];
    uint64_t result = s0 + s1;
    s1 ^= s0;
    s[0] = ((s0 << 55) | (s0 >> 9)) ^ s1 ^ (s1 << 14);
    s[1] = (s1 << 36) | (s1 >> 28);
    return result;
}

int main(int argc, char *argv[])
{
    uint64_t s[2];

    int fd = open(argv[1], O_RDONLY);
    if (fd < 0) {
	perror("open seed");
	exit(1);
    }

    ssize_t len = read(fd, s, sizeof(s));
    if (len != sizeof(s)) {
	perror("read seed");
	exit(2);
    }
    close(fd);

    do {
	for (int i=0; i<BUF_SIZE; i++)	
	    buf[i] = xoroshiro128plus(s);

	len = write(1, buf, sizeof(buf));
    } while (len == sizeof(buf));

    exit(0);
}


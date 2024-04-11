#!/usr/bin/env python3

# Copyright (C) 2024 Herbert Poetzl

import sys

value = int(sys.argv[1], 0)

day = (value & (0b11111 << 27)) >> 27
month = (value & (0b1111 << 23)) >> 23
year = (value & (0b111111 << 17)) >> 17
hour = (value & (0b11111 << 12)) >> 12
minute = (value & (0b111111 << 6)) >> 6
second = value & (0b111111)

print(f"{value:08X} = ", end="")
print(f"{day:02d}.{month:02d}.{year:02d} {hour:02d}:{minute:02d}:{second:02d}")

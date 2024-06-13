#!/usr/bin/env python3

# Copyright (C) 2024 Herbert Poetzl

import os
import sys
import mmap
import struct


def chksum(data):
    csum = 0
    for byte in data:
        csum += byte
    return 256 - (csum & 0xFF)

def hexdump(data, cols=16, digits=2, sep=" "):
    out = [ f"{x:0{digits}X}" for x in data ]
    off = 0

    while len(out):
        print(f"{off:02X}: " + sep.join(out[:cols]),
            file=sys.stderr)
        out = out[cols:]
        off = off + cols

mem = [0]*(3+28)

mem[0] = 0x82   # HDMI_INFOFRAME_TYPE_AVI
mem[1] = 0x02   # version = 2
mem[2] = 0x0D   # HDMI_AVI_INFOFRAME_SIZE (13)

mem[4] |= 0b10 << 0 # S1:S0 Underscan
mem[4] |= 0b00 << 2 # B1:B0 Bar Info
mem[4] |=  0b0 << 4 # A0 Active Format Info present
mem[4] |= 0b00 << 5 # Y1:Y0 RGB
#mem[4] |= 0b10 << 5 # Y1:Y0 YCbCr 444

mem[5] |= 0b1010    # R3:R0 Active Format Aspect Ratio
mem[5] |= 0b10 << 4 # M1:M0 Picture Aspect Ratio
mem[5] |= 0b00 << 6 # C1:C0 Colorimetry

mem[6] |= 0b00 << 0 # SC1:SC0 Non-Uniform Picture Scaling
mem[6] |= 0b10 << 2 # Q1:Q0 RGB Quantiziation Range (Full)
mem[6] |=  0x0 << 4 # EC2:EC0 Extended Colorimetry
mem[6] |=  0b1 << 7 # ITC (IT Content)

mem[7] = 16         # 1920x1080p @59.94/60Hz

mem[8] |= 0b0000    # Pixel Repetition Field (none)
mem[8] |= 0b00 << 4 # Content Type (Graphics)
mem[8] |= 0b01 << 6 # YCC Quantization Range (Full)

mem[3] = chksum(mem[4:16])

hexdump(mem[0:3])
hexdump(mem[4:], cols=7)

sys.stdout.buffer.write(bytes(mem))


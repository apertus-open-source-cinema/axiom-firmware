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

mem[0] = 0x83   # HDMI_INFOFRAME_TYPE_SPD
mem[1] = 0x01   # version = 1
mem[2] = 0x19   # HDMI_SPD_INFOFRAME_SIZE (25)

mem[4:12]  = b"AXIOM\0\0\0"
mem[12:28] = b"Beta\0\0\0\0\0\0\0\0\0\0\0\0"

hexdump(mem[0:3])
hexdump(mem[4:], cols=7)

sys.stdout.buffer.write(bytes(mem))


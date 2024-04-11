#!/usr/bin/env python3

# Copyright (C) 2024 Herbert Poetzl

import os
import sys
import mmap
import struct


m = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
reg = mmap.mmap(m, 0x2000, mmap.MAP_SHARED,
    mmap.PROT_READ | mmap.PROT_WRITE,
    offset=0x80500000)


def hexdump(data, cols=16, digits=2, sep=" "):
    out = [ f"{x:0{digits}X}" for x in data ]
    off = 0

    while len(out):
        print(f"{off:02X}: " + sep.join(out[:cols]))
        out = out[cols:]
        off = off + cols

def reg_get(x):
    res = struct.unpack("<L", reg[x*4:x*4+4])[0]
    # print("reg_get(%d) = %d" % (x, res))
    return res

def reg_set(x, v):
    # print("v=%d" % v)
    reg[x*4:x*4+4] = struct.pack("<L", v)


mem = [0]*32
path = "/dev/stdin" if len(sys.argv) < 2 else sys.argv[1]
offs = 0 if len(sys.argv) < 3 else int(sys.argv[2], 0)

with open(path, "rb") as f:
    head = f.read(4)
    data = f.read(32)

    """
    head = b"\x01\x23\x45\x67"
    data = b"\x80\x81\x82\x83\x84\x85\x86\x87" + \
           b"\x90\x91\x92\x93\x94\x95\x96\x97" + \
           b"\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7" + \
           b"\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7"
    """

    for idx in range(4):
        byte = head[idx]
        for bit in range(8):
            ba = (byte >> bit) & 1
            mem[idx*8 + bit] = ba << 8

    for idx in range(8):
        for bch in range(4):
            byte = data[idx + bch*8]
            for bit in range(4):
                bb = (byte >> (bit*2)) & 1
                bc = (byte >> (bit*2+1)) & 1
                # old implementation
                # mem[idx*4 + bit] |= bb << (bch+4)
                # mem[idx*4 + bit] |= bc << bch
                mem[idx*4 + bit] |= bb << bch
                mem[idx*4 + bit] |= bc << (bch+4)

    hexdump(head)
    hexdump(data)
    hexdump(mem, digits=3)
    
    for idx, val in enumerate(mem):
        reg_set(offs + idx, val)


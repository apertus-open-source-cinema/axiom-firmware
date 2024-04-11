#!/usr/bin/env python3

# Copyright (C) 2024 Herbert Poetzl

import os
import sys
import mmap
import struct


def crc8(data, poly=0x107):
    crc = 0x00
    for byte in data:
        crc ^= byte
        for _ in range(8):
            if crc & 0x1:
                crc ^= poly
            crc >>= 1
    return crc.to_bytes(1)

def hexdump(data, cols=16, digits=2, sep=" "):
    out = [ f"{x:0{digits}X}" for x in data ]
    off = 0

    while len(out):
        print(f"{off:02X}: " + sep.join(out[:cols]),
            file=sys.stderr)
        out = out[cols:]
        off = off + cols

path = "/dev/stdin" if len(sys.argv) < 2 else sys.argv[1]

with open(path, "rb") as f:
    head = f.read(3)
    data = f.read(28)

    mem = head + crc8(head)
    bch = [data[i:i+7] for i in range(0, len(data), 7)]

    for block in bch:
        mem += block + crc8(block)

    hexdump(head)
    hexdump(data, cols=7)
    hexdump(mem)

    sys.stdout.buffer.write(mem)


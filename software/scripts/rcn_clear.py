#!/usr/bin/python

# disable all RCN correction offsets

import os
import sys
import mmap
import struct
import math
from time import sleep

base_addr = 0x18100000
length = 0x08000000

f = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
mem = mmap.mmap(f, length, mmap.MAP_SHARED,
    mmap.PROT_READ | mmap.PROT_WRITE,
    offset=base_addr)

rcn=[0]*6

for i in range(len(rcn)):
    rcn[i] = mmap.mmap(f, 0x2000, mmap.MAP_SHARED,
        mmap.PROT_READ | mmap.PROT_WRITE,
        offset=0x60300000 + 0x2000 * i)

def rcn_get(i, x):
    res = struct.unpack("<L", rcn[i][x*4:x*4+4])[0]
    return res if res < 0x800 else res - 0x1000 

def rcn_set(i, x, v):
    v = int(v)
    v = v if v >= 0 else 0x1000 + v
    rcn[i][x*4:x*4+4] = struct.pack("<L", v)

print('clearing rcn offsets...')

for i in range(3072):
    rcn_set(4 + i%2, i//2, 0)

for i in range(4096):
    rcn_set(2 + i%2, i//2, 0)
    rcn_set(0 + i%2, i//2, 0)

print('done!')

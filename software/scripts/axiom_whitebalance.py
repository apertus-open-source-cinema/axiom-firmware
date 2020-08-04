#!/bin/env python3

import os
import sys
import mmap
import struct
import math
import numpy as np

f = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
mem = mmap.mmap(f, 0x1000, mmap.MAP_SHARED,
                mmap.PROT_READ | mmap.PROT_WRITE,
                offset=0x80200000)

def mat_get(x):
    res = struct.unpack("<l", mem[x*4+0x100:x*4+0x104])[0]
    return res

def mat_set(i, x, v):
    mem[x*4+0x100:x*4+0x104] = struct.pack("<l", v)

argc = len(sys.argv)
if argc == 1:
    for i in range (24):
        print('%.3g'%(mat_get(i)/255), end=' ')
    print()

mat = [mat_get(x)/(1<<8) for x in range(16)]
adj = [mat_get(x)/(1<<8) for x in range(16, 32)]
off = [mat_get(x)/(1<<12) for x in range(32, 36)]

mat = np.array(mat).reshape(4,4)
adj = np.array(adj).reshape(4,4)
off = np.array(off)

print(mat)
print(adj)
print(off)

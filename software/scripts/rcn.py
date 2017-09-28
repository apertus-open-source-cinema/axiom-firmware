#!/bin/env python3

import os
import sys
import mmap
import struct
import math
from time import sleep

base_addr = 0x18100000
length = 0x08000000

debug=[(0,x) for x in range(600,610)]

ddc = { -1 : 'D', 0 : '=', 1 : 'U' }

mid = 0
step = 32

ys=int(sys.argv[1])
ye=int(sys.argv[2])

f = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
mem = mmap.mmap(f, length, mmap.MAP_SHARED,
    mmap.PROT_READ | mmap.PROT_WRITE,
    offset=base_addr)

rcn=[0]*4

rcn[0] = mmap.mmap(f, 0x2000, mmap.MAP_SHARED,
    mmap.PROT_READ | mmap.PROT_WRITE,
    offset=0x60300000)
rcn[1] = mmap.mmap(f, 0x2000, mmap.MAP_SHARED,
    mmap.PROT_READ | mmap.PROT_WRITE,
    offset=0x60302000)
rcn[2] = mmap.mmap(f, 0x2000, mmap.MAP_SHARED,
    mmap.PROT_READ | mmap.PROT_WRITE,
    offset=0x60304000)
rcn[3] = mmap.mmap(f, 0x2000, mmap.MAP_SHARED,
    mmap.PROT_READ | mmap.PROT_WRITE,
    offset=0x60306000)

def rcn_get(i, x):
    res = struct.unpack("<L", rcn[i][x*4:x*4+4])[0]
    # print("rcn_get(%d,%d) = %d" % (i, x, res))
    return res if res < 0x800 else res - 0x1000 

def rcn_set(i, x, v):
    # print("v=%d" % v)
    v = v if v >= 0 else 0x1000 + v
    rcn[i][x*4:x*4+4] = struct.pack("<L", v)
    if x == 0x261:
        print("rcn_set(%d,%d,%d)" % (i, x, v))

def blk_get(x, y):
    idx = (x + y*4096)*8
    pix = struct.unpack("<Q", mem[idx:idx+8])[0]
    c0 = (pix >> 52) & 0xFFF
    c1 = (pix >> 40) & 0xFFF
    c2 = (pix >> 28) & 0xFFF
    c3 = (pix >> 16) & 0xFFF
    c4 = pix & 0xFFF
    return [c0, c1, c2, c3, c4]
    

for x in range(2048):
    for i in range(4):
        rcn_set(i, x, mid)
    

frame = 0

while True:
    sas, sbs, so = [0]*4, [0]*4, [0]*4
    for x in range(2048):
        for i in range(4):
            so[i] += rcn_get(i, x)

        for y in range (ys, ye):
            c = blk_get(x, y)

            for i in range(4):
                if x < 1024:
                    sas[i] += c[i]
                else:
                    sbs[i] += c[i]

    sa = [s/(ye-ys) for s in sas]
    sb = [s/(ye-ys) for s in sbs]

    m, k, r = [0]*4, [0]*4, [0]*4
    for i in range(4):
        m[i], k[i] = (sa[i] + sb[i])/2048, (sb[i] - sa[i])/1024
        r[i] = int(mid - so[i]/2048) 
        # r[i] = int(so[i]/2048 - mid)

    # print(": %d,%d" % (m00, k00))
    frame += 1

    da, sq = [0]*4, [0]*4
    dd, dn = 0, 0
    for x in range(0, 2048):

        a=[0]*4
        for i in range(2):
            a[i] = m[i] + k[i]*(x - 1024)/1024
            o = rcn_get(i, x)
            # cv = c[i] 

            cs = 0
            for y in range (ys, ye):
                c = blk_get(x, y)
                cs += c[i] + c[i+2]

            ca = cs/(2*(ye-ys))
            da = ca - a[i]
            dar = round(da)

            if dar > 0:
                dd = -1
                dn = o + r[i] - step
                if dn > -0x800:
                    rcn_set(i, x, dn)
                else:
                    print("lower limit")
            elif dar < 0:
                dd = 1
                dn = o + r[i] + step
                if dn < 0x800:
                    rcn_set(i, x, dn)
                else:
                    print("upper limit")
            else:
                dd = 0
                dn = o + r[i]
                rcn_set(i, x, dn)

            if (i,x) in debug:
                print("(%d,%03X) r=%4d a=%6.2f ca=%6.2f da=%6.2f  %03x -> %c %03x" %
                    (i, x, r[i], a[i], ca, da, o, ddc[dd], dn))

            sq[i] += da*da

    # nc = [blk_get(x, y) for x in range(2048)]
    # print(nc[599:602])

    sqr = [math.sqrt(x) for x in sq]
    sqs = sum(sqr)
    step = int(min(step, 1 + sqs/100))


    print("frame = %d, sq=%s, step=%d" % (frame, sqr, step))

    # if frame == 5:
    #    break
    sleep(0.1)

#!/usr/bin/python

# set RCN offsets from a dark frame
# example:
#    raw2dng dark*x1*.raw12 --calc-darkframe --no-blackcol     # creates darkframe-x1.pgm
#    python rcn_darkframe.py
#
# arguments: dark frame and black level (both optional, in any order)

import os
import sys
import mmap
import struct
import math
from time import sleep
import numpy
import png

base_addr = 0x18100000
length = 0x08000000

f = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
mem = mmap.mmap(f, length, mmap.MAP_SHARED,
    mmap.PROT_READ | mmap.PROT_WRITE,
    offset=base_addr)

# c0r0_lut => clut_dout_dd(0),
# c1r0_lut => clut_dout_dd(1),
# c0r1_lut => clut_dout_dd(2),
# c1r1_lut => clut_dout_dd(3),
# r0_lut => clut_dout_dd(4),
# r1_lut => clut_dout_dd(5),

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

# http://stackoverflow.com/a/14668590
def read_pnm( filename, endian='>' ):
   fd = open(filename,'rb')
   format, width, height, samples, maxval = png.read_pnm_header( fd )
   pixels = numpy.fromfile( fd, dtype='u1' if maxval < 256 else endian+'u2' )
   return pixels.reshape(height,width,samples)

filename = 'darkframe-x1.pgm'
target_black = 128

for i in range(1, len(sys.argv)):
    try:
        target_black = int(sys.argv[i])
        continue
    except:
        pass
    
    try:
        filename = sys.argv[i]
    except:
        pass

print('target black level: %d' % target_black)

print('reading %s...' % filename)
dark = read_pnm(filename)
dark = dark.astype(numpy.double)
dark = numpy.round((dark - 1024) / 2)

print('computing row/column offsets...')
row_noise = numpy.median(dark, axis=1)
dark[:,:,0] -= row_noise
row_noise = row_noise.flatten()
col_noise_even = numpy.median(dark[0::2,:], axis=0)
col_noise_odd  = numpy.median(dark[1::2,:], axis=0)

target_black = target_black * 4 - 2

# swap lines?
if 1:
    aux = col_noise_even; col_noise_even = col_noise_odd; col_noise_odd = aux;
    aux = dark[0::2,:]; dark[0::2,:] = dark[1::2,:]; dark[1::2,:] = aux

print('setting rcn offsets...')

for i in range(3072):
    rcn_set(4 + i%2, i//2, -row_noise[i] + target_black)

for i in range(4096):
    rcn_set(0 + i%2, i//2, -col_noise_even[i])
    rcn_set(2 + i%2, i//2, -col_noise_odd[i])

print('done!')

#!/bin/env python3

import os
import sys
import mmap
import struct
import math
import numpy as np


M_SHIFT = 1<<8
A_SHIFT = 1<<8
O_SHIFT = 1<<12


f = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
mem = mmap.mmap(f, 0x1000, mmap.MAP_SHARED,
    mmap.PROT_READ | mmap.PROT_WRITE,
    offset=0x80200000)

def reg_get(x):
    v = struct.unpack("<l", mem[x*4+0x100:x*4+0x104])[0]
    return v

def reg_set(x, v):
    mem[x*4+0x100:x*4+0x104] = struct.pack("<l", v)


def mat_get():
    mat = [reg_get(x)/M_SHIFT for x in range(16)]
    return np.flipud(np.array(mat).reshape(4,4))

def adj_get():
    adj = [reg_get(x)/A_SHIFT for x in range(16, 32)]
    return np.flipud(np.array(adj).reshape(4,4))

def off_get():
    off = [reg_get(x)/O_SHIFT for x in range(32, 36)]
    return np.array(off[::-1])


def mat_set(mat):
    val = list(np.flipud(mat).flat)
    for i in range(16):
        reg_set(i, int(val[i]*M_SHIFT))

def adj_set(adj):
    val = list(np.flipud(adj).flat)
    for i in range(16):
        reg_set(i+16, int(val[i]*A_SHIFT))

def off_set(off):
    val = list(off.flat[::-1])
    for i in range(4):
        reg_set(i+32, int(val[i]*O_SHIFT))


def mat3_to4(mat3):
    mat = mat3.transpose()
    mat = np.array([mat[0], mat[1]/2, mat[1]/2, mat[2]]);
    mat = np.insert(mat.transpose(), [3], [0, 0, 0, 0], axis=0)
    return mat
    
def off3_to4(off3):
    off = np.insert(off3, 3, 0, axis=0)
    return off


mat = mat_get()
# adj = adj_get()
off = off_get()

cnt = len(sys.argv) - 1
val = [float(_) for _ in sys.argv[1:]]
write, three = True, True

if __name__ == '__main__':
    if cnt == 0:    # no arguments, just print
        mat = mat_get()
        off = off_get()
        write, three = False, False
    
    elif cnt == 1:  # scalar factor
        mat3 = np.identity(3)*val[0]
        off3 = np.zeros(3)
    
    elif cnt == 2:  # scalar factor and offset
        mat3 = np.identity(3)*val[0]
        off3 = np.ones(3)*val[1]
    
    elif cnt == 3:  # three scalars
        mat3 = np.diag(val[0:3])
        off3 = np.zeros(3)
    
    elif cnt == 4:  # three scalars and one offset
        mat3 = np.diag(val[0:3])
        off3 = np.ones(3)*val[1]
    
    elif cnt == 6:  # three scalars and three offsets
        mat3 = np.diag(val[0:3])
        off3 = np.array(val[3:6])
    
    elif cnt == 9:  # full 3x3 matrix
        mat3 = np.array(val[0:9]).reshape(3,3)
        off3 = np.zeros(3)
    
    elif cnt == 10:  # full 3x3 matrix plus one offset
        mat3 = np.array(val[0:9]).reshape(3,3)
        off3 = np.ones(3)*val[9]
    
    elif cnt == 12:  # full 3x3 matrix plus three offsets
        mat3 = np.array(val[0:9]).reshape(3,3)
        off3 = np.array(val[9:12])
    
    elif cnt == 16:  # full 4x4 matrix
        mat = np.array(val[0:16]).reshape(4,4)
        off = np.zeros(4)
        three = False
    
    elif cnt == 17:  # full 4x4 matrix plus one offset
        mat = np.array(val[0:16]).reshape(4,4)
        off = np.ones(4)*val[16]
        three = False
    
    elif cnt == 20:  # full 4x4 matrix plus four offsets
        mat = np.array(val[0:16]).reshape(4,4)
        off = np.array(val[16:20])
        three = False
    
    else:
        print("Sorry, don't know how to interpret %d values." % cnt)
        exit(1)
    
    if three:
        print(mat3)
        mat = mat3_to4(mat3)
        print(off3)
        off = off3_to4(off3)
    
    print(mat)
    # print(adj)
    print(off)
    
    if write:
        mat_set(mat)
        # adj_set(adj)
        off_set(off)
    

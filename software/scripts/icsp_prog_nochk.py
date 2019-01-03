#!/bin/env python3

# Copyright (C) 2015 Herbert Poetzl

import sys
import serial
import struct

from intelhex import IntelHex
from time import sleep
from icsp import *

tty = "/dev/ttyPS1"

ih = IntelHex(sys.argv[1])
ih.padding = 0xFF

def ih_data(ih, addr, count=32):
    data = []
    mask = 0xFFFF
    for n in range(count):
        l, h = ih[(addr + n)*2], ih[(addr + n)*2 + 1]
        val = (h << 8)|l
        mask &= val
        data.append(val)
    return data, mask

ser = serial.Serial(
    port = tty,
    baudrate = 10000000,
    bytesize = serial.EIGHTBITS,
    parity = serial.PARITY_NONE,
    stopbits = serial.STOPBITS_ONE,
    # interCharTimeout = 0.2,
    timeout = 0.1,
    xonxoff = False,
    rtscts = False,
    dsrdtr = False);

print(icsp_cmd(ser, b'Z'))                      # tristate MCLR (icsp)

print(icsp_cmd(ser, b'L'))                      # take MCLR low (icsp)
print(icsp_cmd(ser, b'#', 9))                   # reset checksum
# print(icsp_cmd(ser, b'%', 5))                 # reset stats
print(icsp_cmd(ser, b'^'))                      # enter LVP

print("programming code memory ...")
for addr in range(0, 0x4000, 0x20):
    data, mask = ih_data(ih, addr)

    first = addr == 0
    if mask != 0xFFFF:
        icsp_loadn(ser, data, first)
        icsp_iprog(ser)
        # print(addr, data)
    else:
        if first:
            icsp_advance(ser, 31)
        else:
            icsp_advance(ser, 32)

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)


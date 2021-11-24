#!/bin/env python3

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

import sys
import serial
import struct

from intelhex import IntelHex
from time import sleep
from axiom_icsp import *

tty = "/dev/ttyPS1"
msize = 0x1000
csize = 4

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

icsp_enter_lvp(ser)

print("reading config memory ...")
icsp_load_conf(ser)
conf = icsp_read_data(ser, 0x11)
print([hex(_) for _ in conf])

prog = False
if conf[5] == 0x2004 and conf[6] == 0x303b:
    print("PIC16F18344 found.")
    prog = True
if conf[5] == 0x2004 and conf[6] == 0x303d:
    print("PIC16LF18344 found.")
    prog = True

if prog:

    icsp_load_addr(ser, 0x8000)
    icsp_bulk_erase(ser)

    icsp_load_addr(ser, 0x0000)

    print("programming code memory ...")
    for addr in range(0, msize, 0x20):
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

        print("%04X/%04X" % (addr, msize), end="\r");

    icsp_load_addr(ser, 0x0000)

    print("verifying code memory ...")
    for addr in range(0, msize, 0x20):
        data, mask = ih_data(ih, addr)
        data = [_ & 0x3FFF for _ in data]
        read = icsp_read_data(ser, 0x20)

        if read != data:
            print("mismatch @%04X:" % (addr))
            print("wrote\t", [hex(_) for _ in data])
            print("read\t", [hex(_) for _ in read])

        print("%04X/%04X" % (addr, msize), end="\r");


    print("programming user id ...")
    data, mask = ih_data(ih, 0x8000, 4)         # user id
    print([hex(_) for _ in data])

    icsp_load_conf(ser)
    icsp_loadn(ser, data[0:4], True)
    icsp_iprog(ser, delay=5.0)                  # internal programming

    print("verifying user id ...")
    data = [_ & 0x3FFF for _ in data]

    icsp_load_conf(ser)
    read = icsp_read_data(ser, 0x4)
    if read != data:
        print("mismatch:\t", [hex(_) for _ in read])

    print("programming config words ...")
    data, mask = ih_data(ih, 0x8007, csize)     # config words
    print([hex(_) for _ in data])

    icsp_load_conf(ser)
    icsp_load_data(ser, data[0], 0x7)
    icsp_iprog(ser, delay=5.0)                  # internal programming
    for i in range(1, csize):
        icsp_load_data(ser, data[i], 1)
        icsp_iprog(ser, delay=5.0)              # internal programming

    print("verifying config words ...")
    data = [_ & 0x3FFF for _ in data]

    icsp_load_addr(ser, 0x8007)
    read = icsp_read_data(ser, csize)

    if read != data:
        print("mismatch:\t", [hex(_) for _ in read])

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)

exit(0)



#!/bin/env python3

# SPDX-FileCopyrightText: © 2016 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

import sys
import serial
import struct

from intelhex import IntelHex
from smbus import SMBus
from time import sleep
from axiom_icsp import *
from axiom_via import *

tty = "/dev/ttyPS1"

sel = sys.argv[1]

ih = IntelHex(sys.argv[2])
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

i2c2 = SMBus(2)

print(icsp_cmd(ser, b'Z'))                      # tristate MCLR (icsp)

via_none(i2c2)
via_sel(i2c2, sel)

print(icsp_cmd(ser, b'H'))                      # take MCLR high (icsp)
print(icsp_cmd(ser, b'#', 9))                   # reset checksum
# print(icsp_cmd(ser, b'%', 5))                 # reset stats
print(icsp_cmd(ser, b'[^]', 0))                 # enter LVP

icsp_cmd(ser, b'[X0=]', 0)                      # switch to config mem
print("reading config memory ...")

conf = icsp_read_data(ser, 16)
# print([hex(_) for _ in conf])

prog = False
if conf[5] == 0x2000 and conf[6] == 0x305b:
    print("pic16f1718 found.")
    prog = True

if prog:
    icsp_cmd(ser, b'9!3100.')                   # bulk erase program memory
    sleep(0.005)

    icsp_cmd(ser, b'16!')                       # reset address

    print("programming ...")
    addr = 0
    while addr < 0x4000:
        data, mask = ih_data(ih, addr)

        first = addr == 0
        if mask != 0xFFFF:
            icsp_load_data(ser, data, first)
            icsp_iprog(ser)                     # internal programming
            # print(addr, data)
        else:
            if first:
                icsp_cmd(ser, b'+'*31)          # advance
            else:
                icsp_cmd(ser, b'+'*32)          # advance

        addr += 0x20
        print("%04X/%04X" % (addr, 0x4000), end="\r");

    print("programming config ...")
    data, mask = ih_data(ih, 0x8000, 4)         # user id
    data[3] = int(sel, 16)                      # UID[3] = sel
    print([hex(_) for _ in data])

    icsp_load_conf(ser, 0)
    icsp_load_data(ser, data[0:4], True)
    icsp_iprog(ser, delay=5.0)                  # internal programming

    data, mask = ih_data(ih, 0x8007, 2)         # config words
    print([hex(_) for _ in data])

    icsp_load_conf(ser, data[0], 0x7)
    icsp_iprog(ser, delay=5.0)                  # internal programming
    icsp_load_conf(ser, data[1], 0x8)
    icsp_iprog(ser, delay=5.0)                  # internal programming

else:
    print("pic16f1718 not found")

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)

via_none(i2c2)


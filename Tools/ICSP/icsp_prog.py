#!/bin/env python3

# Copyright (C) 2015 Herbert Poetzl

import sys
import serial
import struct

from intelhex import IntelHex
from smbus import SMBus
from time import sleep
from icsp import *

tty = "/dev/ttyPS1"
sel = sys.argv[1] if len(sys.argv) > 1 else "A"

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
    timeout = 10.0,
    xonxoff = False,
    rtscts = False,
    dsrdtr = False);

i2c0 = SMBus(0)
i2c2 = SMBus(2)

print(icsp_cmd(ser, b'Z'))                      # tristate MCLR (icsp)

if sel == "A":                                  # take A_!RST low
    i2c2.write_byte(0x70, 0x5)                  # steer mux
    ioa = i2c0.read_byte_data(0x23, 0x14)
    i2c0.write_byte_data(0x23, 0x14, ioa&~0x10)

elif sel == "B":                                # take B_!RST low
    i2c2.write_byte(0x70, 0x4)                  # steer mux
    iob = i2c0.read_byte_data(0x22, 0x14)
    i2c0.write_byte_data(0x22, 0x14, iob&~0x10)

print(icsp_cmd(ser, b'L'))                      # take MCLR low (icsp)
print(icsp_cmd(ser, b'#', 9))                   # reset checksum
# print(icsp_cmd(ser, b'%', 5))                 # reset stats
print(icsp_cmd(ser, b'^'))                      # enter LVP

icsp_cmd(ser, b'[X0=]', 0)                      # switch to config mem
print("reading config memory ...")

conf = icsp_read_data(ser, 16)
# print([hex(_) for _ in conf])

if conf[5] == 0x2000 and conf[6] == 0x305b:
    print("pic16f1718 found.")

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

    print("programming config ...")
    data, mask = ih_data(ih, 0x8000, 4)         # user id
    print([hex(_) for _ in data])

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

if sel == "A":                                  # bring A_!RST high again
    i2c0.write_byte_data(0x23, 0x14, ioa|0x10)
elif sel == "B":                                # bring B_!RST high again
    i2c0.write_byte_data(0x22, 0x14, iob|0x10)
i2c2.write_byte(0x70, 0x0)                      # disable mux


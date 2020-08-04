#!/bin/env python3

# Copyright (C) 2015-2017 Herbert Poetzl

import sys
import serial
import struct

from intelhex import IntelHex
from smbus import SMBus
from time import sleep
from axiom_icsp import *

tty = "/dev/ttyPS1"
sel = sys.argv[1] if len(sys.argv) > 1 else "A"
ver = "0.36"

ih = IntelHex()

ser = serial.Serial(
    port = tty,
    baudrate = 10000000,
    bytesize = serial.EIGHTBITS,
    parity = serial.PARITY_NONE,
    stopbits = serial.STOPBITS_ONE,
    # interCharTimeout = 0.2,
    timeout = 0.01,
    xonxoff = False,
    rtscts = False,
    dsrdtr = False);

i2c0 = SMBus(0)
i2c2 = SMBus(2)

print(icsp_cmd(ser, b'Z'))                      # tristate MCLR (icsp)

if sel == "A":                                  # take A_!RST low
    if ver == "0.36":
        i2c2.write_byte(0x30, 0x2)              # steer mux
    else:
        i2c2.write_byte(0x70, 0x5)              # steer mux
    ioa = i2c0.read_byte_data(0x23, 0x14)
    i2c0.write_byte_data(0x23, 0x14, ioa&~0x10)

elif sel == "B":                                # take B_!RST low
    if ver == "0.36":
        i2c2.write_byte(0x30, 0x1)              # steer mux
    else:
        i2c2.write_byte(0x70, 0x4)              # steer mux
    iob = i2c0.read_byte_data(0x22, 0x14)
    i2c0.write_byte_data(0x22, 0x14, iob&~0x10)

# if ver == "0.36":
#    print("mux = 0x%02x" % i2c2.read_byte(0x30))

print(icsp_cmd(ser, b'L'))                      # take MCLR low (icsp)
print(icsp_cmd(ser, b'#', 9))                   # reset checksum
print(icsp_enter_lvp(ser))                      # enter LVP

print("dumping program memory ...")

data = icsp_read_data(ser, 0x4000)
for a in range(0x0000, 0x4000):
    val = data[a]
    ih.puts(a*2, struct.pack("<h", val))

icsp_cmd(ser, b'[X0=]', 0)                      # switch to config mem

print("dumping config memory ...")

data = icsp_read_data(ser, 0x11)
for a in range(0x8000, 0x8011):
    val = data[a - 0x8000]
    ih.puts(a*2, struct.pack("<h", val))

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)

if ver == "0.36":
    print("mux = 0x%02x" % i2c2.read_byte(0x30))

if sel == "A":                                  # bring A_!RST high again
    i2c0.write_byte_data(0x23, 0x14, ioa|0x10)
elif sel == "B":                                # bring B_!RST high again
    i2c0.write_byte_data(0x22, 0x14, iob|0x10)
elif sel == "P":
    pass
else:
    if ver == "0.36":
        i2c2.write_byte(0x30, 0x0)              # disable mux
    else:
        i2c2.write_byte(0x70, 0x0)              # disable mux

ih.tofile(sys.argv[2], "hex")

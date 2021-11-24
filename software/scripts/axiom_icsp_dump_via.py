#!/bin/env python3

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
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

i2c = SMBus(2)


via_mchp(ser, i2c, sel)

print(icsp_cmd(ser, b'#', 9))                   # reset checksum
# print(icsp_cmd(ser, b'%', 5))                 # reset stats

icsp_enter_lvp(ser)

print("dumping program memory ...")

data = icsp_read_data(ser, 0x4000)
for a in range(0x0000, 0x4000):
    val = data[a]
    ih.puts(a*2, struct.pack("<h", val))

icsp_load_conf(ser)

print("dumping config memory ...")

data = icsp_read_data(ser, 0x11)
for a in range(0x8000, 0x8011):
    val = data[a - 0x8000]
    ih.puts(a*2, struct.pack("<h", val))

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)

ih.tofile(sys.argv[2], "hex")

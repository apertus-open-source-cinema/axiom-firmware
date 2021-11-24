#!/bin/env python3

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

import sys
import serial
import struct

from smbus import SMBus
from time import sleep
from axiom_icsp import *

tty = "/dev/ttyPS1"

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


def read16():
    print("reading 16 words ...")
    data = icsp_read_data(ser, 0x10)
    print([hex(_) for _ in data])

def cmd0B():
    print("end programming ...")
    icsp_cmd(ser, b'[B!]', 0)



print(icsp_cmd(ser, b'Z'))                      # tristate MCLR (icsp)

print(icsp_cmd(ser, b'L'))                      # take MCLR low (icsp)
print(icsp_cmd(ser, b'#', 9))                   # reset checksum
# print(icsp_cmd(ser, b'%', 5))                 # reset stats
print(icsp_cmd(ser, b'[^]', 0))                 # enter LVP

read16()
cmd0B()
read16()

print(icsp_cmd(ser, b'[^]', 0))                 # enter LVP
read16()

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)


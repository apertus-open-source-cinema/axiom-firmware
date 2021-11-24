#!/bin/env python3

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

import sys
import serial

from axiom_icsp import *

ser = serial.Serial(
    port = sys.argv[1],
    baudrate = 10000000,
    bytesize = serial.EIGHTBITS,
    parity = serial.PARITY_NONE,
    stopbits = serial.STOPBITS_ONE,
    timeout = 1.0,
    xonxoff = False,
    rtscts = False,
    dsrdtr = False);

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)
print(icsp_cmd(ser, b'P', 2))                   # check status


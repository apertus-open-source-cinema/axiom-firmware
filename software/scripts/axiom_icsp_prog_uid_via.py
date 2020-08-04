#!/bin/env python3

# Copyright (C) 2016 Herbert Poetzl

import sys
import serial
import struct

from smbus import SMBus
from time import sleep
from axiom_icsp import *
from axiom_via import *

tty = "/dev/ttyPS1"

sel = sys.argv[1]

data = [int(_, 0) for _ in sys.argv[2:]]
data += [0]*(4 - len(data))

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
print([hex(_) for _ in conf])

prog = False
if conf[5] == 0x2000 and conf[6] == 0x305b:
    print("pic16f1718 found.")
    prog = True

if prog:
    icsp_load_conf(ser, 0)
    icsp_load_data(ser, data[0:4], True)
    icsp_iprog(ser, delay=5.0)                  # internal programming

    icsp_load_conf(ser, 0)
    conf = icsp_read_data(ser, 16)
    print([hex(_) for _ in conf])
else:
    print("pic16f1718 not found")

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)

via_none(i2c2)


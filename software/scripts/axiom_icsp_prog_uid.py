#!/bin/env python3

# Copyright (C) 2015 Herbert Poetzl

import sys
import serial
import struct

from intelhex import IntelHex
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
    timeout = 0.1,
    xonxoff = False,
    rtscts = False,
    dsrdtr = False);

print(icsp_cmd(ser, b'Z'))                      # tristate MCLR (icsp)

print(icsp_cmd(ser, b'L'))                      # take MCLR low (icsp)
print(icsp_cmd(ser, b'#', 9))                   # reset checksum
# print(icsp_cmd(ser, b'%', 5))                 # reset stats
print(icsp_cmd(ser, b'^'))                      # enter LVP

print("reading config memory ...")

icsp_load_conf(ser)
conf = icsp_read_data(ser, 0x11)
print([hex(_) for _ in conf])

prog = False
if conf[5] == 0x2000 and conf[6] == 0x305b:
    print("pic16f1718 found.")
    prog = True

if conf[5] == 0x2004 and conf[6] == 0x3042:
    print("pic16f1708 found.")
    prog = True

if prog:
    icsp_reset_addr(ser) 
    icsp_load_conf(ser)

    print("programming user id ...")
    data = [int(_, 0) for _ in sys.argv[1:]]
    data += [0x3FFF]*4
    print([hex(_) for _ in data[0:4]])

    icsp_load_conf(ser)
    icsp_loadn(ser, data[0:4], True)
    icsp_iprog(ser, delay=5.0)                  # internal programming

    print("verifying user id ...")
    data = [_ & 0x3FFF for _ in data]

    icsp_reset_addr(ser) 
    icsp_load_conf(ser)
    read = icsp_read_data(ser, 0x4)

    if read != data:
        print("mismatch:\t", [hex(_) for _ in read])

else:
    print("pic16f1718 not found")

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)


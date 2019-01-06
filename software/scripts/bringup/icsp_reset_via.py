#!/bin/env python3

# Copyright (C) 2015 Herbert Poetzl

import sys
import serial
import struct

from time import sleep
from icsp import *

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

# print(icsp_cmd(ser, b'L'))                    # take MCLR low (icsp)
sleep(0.05)
print(icsp_cmd(ser, b'H'))                      # take MCLR high (icsp)

print(icsp_cmd(ser, b'^'))                      # enter LVP
icsp_reset_addr(ser) 
icsp_load_conf(ser)
icsp_bulk_erase(ser)
sleep(0.010)

print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)


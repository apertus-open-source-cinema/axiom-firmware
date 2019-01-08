#!/bin/env python3

# Copyright (C) 2017 Herbert Poetzl

import sys
import serial
import struct

from intelhex import IntelHex
from smbus import SMBus
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

print(icsp_cmd(ser, b'Z'))                      # tristate MCLR (icsp)

print(icsp_cmd(ser, b'L'))                      # take MCLR low (icsp)
print(icsp_cmd(ser, b'#', 9))                   # reset checksum
# print(icsp_cmd(ser, b'%', 5))                 # reset stats
print(icsp_cmd(ser, b'^'))                      # enter LVP

icsp_cmd(ser, b'[X0=]', 0)                      # switch to config mem
print("reading config memory ...")

conf = icsp_read_data(ser, 0x11)

print("User", ["%04X" % _ for _ in conf[0:4]])
print("ID",   ["%04X" % _ for _ in conf[5:7]])
print("Conf", ["%04X" % _ for _ in conf[7:9]])
print("Cal",  ["%04X" % _ for _ in conf[9:13]])

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)


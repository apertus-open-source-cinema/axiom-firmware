#!/bin/env python3

import sys
import serial
import struct

from smbus import SMBus
from time import sleep
from icsp import *
from via import *


tty = "/dev/ttyPS1"

sel = sys.argv[1]

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
sleep(0.001)

print(icsp_cmd(ser, b'H'))                      # take MCLR high (icsp)
print(icsp_cmd(ser, b'#', 9))                   # reset checksum

# print(icsp_cmd(ser, b'%', 5))                 # reset stats
icsp_cmd(ser, b'[^]', 0)                        # enter LVP

icsp_cmd(ser, b'[X0=]', 0)                      # switch to config mem
data = icsp_read_data(ser, 17)

print(["%04X" % _ for _ in data[0:4]])
print(["%04X" % _ for _ in data[5:7]])
print(["%04X" % _ for _ in data[7:9]])
print(["%04X" % _ for _ in data[9:13]])
print(["%04X" % _ for _ in data[15:17]])

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)

via_none(i2c2)


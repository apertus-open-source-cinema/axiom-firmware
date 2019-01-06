#!/bin/env python3

import sys
import serial
import struct

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

i2c2 = SMBus(2)

if len(sys.argv) > 1:
    adr = int(sys.argv[1], 0)
else:
    adr = 0x3F


for i in range(65536):
    cnt = i2c2.read_byte_data(adr, 0x41)
    print(cnt, end="/")
    dat = i2c2.read_i2c_block_data(adr, 0x42, 16) 
    print(len(dat), end=",")

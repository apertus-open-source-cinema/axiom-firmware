#!/bin/env python3

# Copyright (C) 2015 Herbert Poetzl

import sys
import serial
import struct

from smbus import SMBus
from time import sleep
from icsp import *

tty = "/dev/ttyPS1"
sel = sys.argv[1] if len(sys.argv) > 1 else "N"

ser = serial.Serial(
    port = tty,
    baudrate = 10000000,
    bytesize = serial.EIGHTBITS,
    parity = serial.PARITY_NONE,
    stopbits = serial.STOPBITS_ONE,
    # interCharTimeout = 0.2,
    timeout = 10.0,
    xonxoff = False,
    rtscts = False,
    dsrdtr = False);

i2c0 = SMBus(0)
i2c2 = SMBus(2)

print(icsp_cmd(ser, b'Z'))                      # tristate MCLR (icsp)

if sel == "A":                                  # toggle A_!RST 
    print("selecting RFW ...")
    i2c2.write_byte(0x70, 0x5)                  # steer mux
    ioa = i2c0.read_byte_data(0x23, 0x14)
    i2c0.write_byte_data(0x23, 0x14, ioa&~0x10)
    i2c0.write_byte_data(0x23, 0x14, ioa|0x10)

elif sel == "B":                                # toggle B_!RST
    print("selecting RFE ...")
    i2c2.write_byte(0x70, 0x4)                  # steer mux
    iob = i2c0.read_byte_data(0x22, 0x14)
    i2c0.write_byte_data(0x22, 0x14, iob&~0x10)
    i2c0.write_byte_data(0x22, 0x14, iob|0x10)

elif sel == "N":                               
    print("disabling MUX ...")
    i2c2.write_byte(0x70, 0x0)                  # disable mux


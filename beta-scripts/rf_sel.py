#!/bin/env python3

# Copyright (C) 2015 Herbert Poetzl

import sys
import serial
import struct

from smbus import SMBus
from time import sleep
from icsp import *

sel = sys.argv[1] if len(sys.argv) > 1 else "N"

i2c0 = SMBus(0)
i2c2 = SMBus(2)

if sel == "A":                                  # toggle A_!RST 
    print("selecting RFW [bus A] ...")
    i2c2.write_byte(0x70, 0x5)                  # steer mux
    ioa = i2c0.read_byte_data(0x23, 0x14)
    i2c0.write_byte_data(0x23, 0x14, ioa&~0x10)
    i2c0.write_byte_data(0x23, 0x14, ioa|0x10)

elif sel == "B":                                # toggle B_!RST
    print("selecting RFE [bus B] ...")
    i2c2.write_byte(0x70, 0x4)                  # steer mux
    iob = i2c0.read_byte_data(0x22, 0x14)
    i2c0.write_byte_data(0x22, 0x14, iob&~0x10)
    i2c0.write_byte_data(0x22, 0x14, iob|0x10)

elif sel == "N":                               
    print("disabling MUX ...")
    i2c2.write_byte(0x70, 0x0)                  # disable mux


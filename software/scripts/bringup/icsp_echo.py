#!/bin/env python3

import sys
import serial
import struct
import string
import random

from smbus import SMBus
from time import sleep
from icsp import *


ser = serial.Serial(
    port = sys.argv[1],
    baudrate = 10000000,
    bytesize = serial.EIGHTBITS,
    parity = serial.PARITY_NONE,
    stopbits = serial.STOPBITS_ONE,
    # interCharTimeout = 0.2,
    timeout = 1.0,
    xonxoff = False,
    rtscts = False,
    dsrdtr = False);

i2c = SMBus(0)

iop = i2c.read_byte_data(0x23, 0x14)
i2c.write_byte_data(0x23, 0x14, iop&~0x10)      # take A_!RST low

print(icsp_cmd(ser, b'#', 9))
print(icsp_cmd(ser, b'0123456789'))
print(icsp_cmd(ser, b'ABCDEF'))

random.seed(42)
for n in range(100):
    str = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(64))
    print(icsp_cmd(ser, b'\\' + str.encode('ASCII') + b'\\'))
print(icsp_cmd(ser, b'#', 9))

i2c.write_byte_data(0x23, 0x14, iop|0x10)       # bring A_!RST high again



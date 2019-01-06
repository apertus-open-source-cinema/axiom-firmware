#!/bin/env python3

import sys
import serial
import struct

from smbus import SMBus
from time import sleep
from icsp import *
from via import *


tty = "/dev/ttyPS1"

cmd = int(sys.argv[1], 0)
val = int(sys.argv[2], 0)

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
i2c2.write_byte(0x0, cmd)
# i2c2.write_byte_data(0x0, cmd, val)


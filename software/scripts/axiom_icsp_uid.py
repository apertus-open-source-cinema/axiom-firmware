#!/bin/env python3

import sys
import serial
import struct

from smbus import SMBus
from time import sleep
from axiom_icsp import *

tty = "/dev/ttyPS1"
sel = sys.argv[1] if len(sys.argv) > 1 else "A"


ser = serial.Serial(
    port = tty,
    baudrate = 10000000,
    bytesize = serial.EIGHTBITS,
    parity = serial.PARITY_NONE,
    stopbits = serial.STOPBITS_ONE,
    # interCharTimeout = 0.2,
    timeout = 1.0,
    xonxoff = False,
    rtscts = False,
    dsrdtr = False);

i2c0 = SMBus(0)
i2c2 = SMBus(2)

print(icsp_cmd(ser, b'Z'))                      # tristate MCLR (icsp)

if sel == "A":                                  # take A_!RST low
    i2c2.write_byte(0x70, 0x5)                  # steer mux
    ioa = i2c0.read_byte_data(0x23, 0x14)
    i2c0.write_byte_data(0x23, 0x14, ioa&~0x10)

elif sel == "B":                                # take B_!RST low
    i2c2.write_byte(0x70, 0x4)                  # steer mux
    iob = i2c0.read_byte_data(0x22, 0x14)
    i2c0.write_byte_data(0x22, 0x14, iob&~0x10)

print(icsp_cmd(ser, b'L'))                      # take MCLR low (icsp)
print(icsp_cmd(ser, b'#', 9))                   # reset checksum
# print(icsp_cmd(ser, b'%', 5))                 # reset stats
icsp_cmd(ser, b'[^]', 0)                        # enter LVP

icsp_cmd(ser, b'[X0=]', 0)                      # switch to config mem
# print(icsp_cmd(ser, b'%', 5))                 # check stats

# print(icsp_cmd(ser, b'[R?+R?+]', 8))
# print(icsp_cmd(ser, b'\0', 10))

data = icsp_read_data(ser, 4)
print(["%04X" % _ for _ in data])

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)

if sel == "A":                                  # bring A_!RST high again
    i2c0.write_byte_data(0x23, 0x14, ioa|0x10)
elif sel == "B":                                # bring B_!RST high again
    i2c0.write_byte_data(0x22, 0x14, iob|0x10)
elif sel == "P":
    pass
else:
    i2c2.write_byte(0x70, 0x0)                  # disable mux



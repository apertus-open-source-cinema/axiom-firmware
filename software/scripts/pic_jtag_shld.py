#!/bin/env python3

import sys
import serial
import struct

from smbus import SMBus
from time import sleep
from bitarray import bitarray
from jtag import *


devid = { 
    "00000001001010111001000001000011" : "MXO2-640HC",
    "00000001001010111010000001000011" : "MXO2-1200HC",
    "00000001001010111011000001000011" : "MXO2-2000HC" }

i2c = SMBus(2)


i2c.write_byte(0x38, 0x01)  # TDO_W input
i2c.write_byte(0x3A, 0xFF)  # all pullups

i2c.write_byte(0x39, 0x00) 

jtag_tms(i2c, "11111111")   # goto reset
jtag_tms(i2c, "01100")      # goto Shift-IR
# shift in IDCODE [11100000]
jtag_tdi(i2c, "00000111")
jtag_tms(i2c, "1100")       # goto Shift-DR
idcode = jtag_tdo(i2c, 32)  # read idcode
dev = devid[idcode]
print("found %s [%s]" % (dev, idcode))

if dev == "MXO2-640HC":
    shld_north = [107,105,103,101, 99, 97, 95, 93, 91, 89]
    shld_south = [  7,  5, 11,  9, 15, 13, 17, 19, 25, 27]
    bits = ['0']*(19*8)
elif dev == "MXO2-1200HC":
    shld_north = [143,141,139,137,135,133,127,125,123,121]
    shld_south = [ 11,  9, 15, 13, 19, 17, 25, 27, 33, 35]
    bits = ['0']*(26*8)
elif dev == "MXO2-2000HC":
    shld_north = [287,285,279,277,271,269,255,253,247,245]
    shld_south = [ 19, 17, 27, 25, 35, 33, 53, 55, 65, 67]
    bits = ['0']*(53*8)

val_north = int(sys.argv[1], 0)
val_south = int(sys.argv[2], 0)

if len(sys.argv) > 3:
    shld_north, shld_south = shld_south[::-1], shld_north[::-1]

for b in range(10):
    if val_north & (1<<b) > 0:
        bits[shld_north[b]] = '1'
    if val_south & (1<<b) > 0:
        bits[shld_south[b]] = '1'

jtag_tms(i2c, "11111111")   # goto reset
jtag_tms(i2c, "01100")      # goto Shift-IR
# shift in EXTEST [00010101]
jtag_tdi(i2c, "10101000")
jtag_tms(i2c, "1100")       # goto Shift-DR

seq = "".join(bits)
# print(seq)
jtag_tdi(i2c, seq)

# goto Update-DR and then Run-Test/Idle
jtag_tms(i2c, "110")      

i2c.write_byte(0x39, 0x00) 



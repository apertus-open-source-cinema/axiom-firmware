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
    cso = [ 21, 31, 29, 23]
    bits = ['0']*(19*8)
elif dev == "MXO2-1200HC":
    cso = [ 29, 39, 37, 31]
    bits = ['0']*(26*8)
elif dev == "MXO2-2000HC":
    cso = [ 57, 75, 73, 59]
    bits = ['0']*(53*8)
elif dev == "<zeros>":
    cso = [ 57, 75, 73, 59]
    bits = ['0']*(53*8)

val = int(sys.argv[1], 0)

for b in range(8):
    if val & (1<<b) > 0:
        bits[cso[b]] = '1'

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



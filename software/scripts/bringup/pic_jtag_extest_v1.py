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
    bits = ['0']*(19*8)
elif dev == "MXO2-1200HC":
    bits = ['0']*(26*8)
elif dev == "MXO2-2000HC":
    bits = ['0']*(53*8)


    jtag_tms(i2c, "11111111")   # goto reset
    jtag_tms(i2c, "0")          # goto Run Test/Idle

# for b in range(len(bits)):
for b in range(2):
    test = ['1']*(len(bits))
    test[b] = '0'
    oseq = "".join(test)

    jtag_tms(i2c, "1100")       # goto Shift-IR

    jtag_tdi(i2c, "00111000")   # shift in SAMPLE [00011100]
    jtag_tms(i2c, "1110")   # goto Shift-DR

    iseq = jtag_tdo(i2c, len(bits))
    print(iseq)

    jtag_tms(i2c, "11110")      # goto Shift-IR

    jtag_tdi(i2c, "10101000")   # shift in EXTEST [00010101]
    jtag_tms(i2c, "1110")   # goto Shift-DR

    # iseq = jtag_tdo(i2c, len(bits))
    # print(iseq)

    # print(seq)
    jtag_tdi(i2c, oseq)
    
    jtag_tms(i2c, "11")     # goto Update-DR
    jtag_tms(i2c, "00")     # goto Run Test/Idle     


jtag_tms(i2c, "1100")   # goto Shift-DR

iseq = jtag_tdo(i2c, len(bits))
print(iseq)


i2c.write_byte(0x39, 0x00) 



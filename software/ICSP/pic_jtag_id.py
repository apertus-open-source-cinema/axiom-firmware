#!/bin/env python3

# Copyright (C) 2015 Herbert Poetzl

import sys
import serial
import struct

from smbus import SMBus
from time import sleep
from bitarray import bitarray
from jtag import *


def rev(s):
    return s[::-1]

def h2b(s):
    return ''.join([format(int(_,16),"04b") for _ in s])

def b2h(s):
    return ''.join([format(int(''.join(_),2),"X") for _ in zip(*[iter(s)]*4)])
    

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
jtag_tdi(i2c, rev("11100000"))
jtag_tms(i2c, "1100")       # goto Shift-DR
idcode = jtag_tdo(i2c, 32)  # read idcode
dev = devid[idcode]
print("found %s [%s]" % (dev, idcode))

jtag_tms(i2c, "11111111")   # goto reset

jtag_tms(i2c, "01100")      # goto Shift-IR
# shift in USERCODE (0xC0) 
jtag_tdi(i2c, rev(h2b("C0")))
jtag_tms(i2c, "1100")       # goto Shift-DR
usercode = jtag_tdo(i2c, 32) # read usercode
print("usercode %s [%s]" % (b2h(usercode), usercode))

jtag_tms(i2c, "11111111")   # goto reset

jtag_tms(i2c, "01100")      # goto Shift-IR
# shift in UIDCODE_PUB (0x19) 
jtag_tdi(i2c, rev(h2b("19")))
jtag_tms(i2c, "1100")       # goto Shift-DR
traceid = jtag_tdo(i2c, 64) # read traceid
print("traceid %s:%s [%s:%s]" % 
    (b2h(traceid[:8]), b2h(traceid[8:]),
    traceid[:8], traceid[8:]))

jtag_tms(i2c, "11111111")   # goto reset

i2c.write_byte(0x39, 0x00) 



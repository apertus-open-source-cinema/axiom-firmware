#!/bin/env python3

import sys
import serial
import struct

from smbus import SMBus
from time import sleep
from bitarray import bitarray
from axiom_jtag import *


devid = { 
    "00000001001010111001000001000011" : "MXO2-640HC",
    "00000001001010111010000001000011" : "MXO2-1200HC",
    "00000001001010111011000001000011" : "MXO2-2000HC" }

i2c = SMBus(2)

base = 0x40

i2c.write_byte(base + 0x28, 0x01)  # TDO_W input
i2c.write_byte(base + 0x2A, 0xFF)  # all pullups

i2c.write_byte(base + 0x29, 0x00) 

jtag_tms(i2c, base, "11111111")   # goto reset
jtag_tms(i2c, base, "01100")      # goto Shift-IR
# shift in IDCODE [11100000]
jtag_tdi(i2c, base, "00000111")
jtag_tms(i2c, base, "1100")       # goto Shift-DR
idcode = jtag_tdo(i2c, base, 32)  # read idcode
dev = devid[idcode]
print("found %s [%s]" % (dev, idcode))

if dev == "MXO2-640HC":
    pcie_north = [133,127,117,119,115,113,111,109]
    pcie_south = [  1,  3,149,151,145,147,135,141]
    cso = [ 21, 31, 29, 23]
    bits = ['0']*(19*8)
elif dev == "MXO2-1200HC":
    pcie_north = [181,171,157,159,151,149,147,145]
    pcie_south = [  5,  7,205,207,197,199,183,189]
    cso = [ 29, 39, 37, 31]
    bits = ['0']*(26*8)
elif dev == "MXO2-2000HC":
    pcie_north = [365,343,317,319,303,301,295,293]
    pcie_south = [  9, 11,421,423,405,407,367,381]
    cso = [ 57, 75, 73, 59]
    bits = ['0']*(53*8)

val_north = int(sys.argv[1], 0)
val_south = int(sys.argv[2], 0)

for b in range(8):
    if val_north & (1<<b) > 0:
        bits[pcie_north[b]] = '1'
    if val_south & (1<<b) > 0:
        bits[pcie_south[b]] = '1'

for b in range(4):
    bits[cso[b]] = '1'

jtag_tms(i2c, base, "11111111")   # goto reset
jtag_tms(i2c, base, "01100")      # goto Shift-IR
# shift in EXTEST [00010101]
jtag_tdi(i2c, base, "10101000")
jtag_tms(i2c, base, "1100")       # goto Shift-DR

seq = "".join(bits)
# print(seq)
jtag_tdi(i2c, base, seq)

# goto Update-DR and then Run-Test/Idle
jtag_tms(i2c, base, "110")      

i2c.write_byte(base + 0x29, 0x00) 



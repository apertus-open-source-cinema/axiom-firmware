#!/bin/env python3

# SPDX-FileCopyrightText: © 2016 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only


import sys
import serial
import struct

from smbus import SMBus
from time import sleep
from axiom_icsp import *


tty = "/dev/ttyPS1"

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


adc_ch = [ "AN0", "AN1", "AN2", "AN3", "AN4",
    "AN8", "AN9", "AN10", "AN11", "AN12",
    "AN13", "AN14", "AN15", "AN16", "AN17",
    "AN18", "AN19", "AN27", "DAC2", "TEMP",
    "DAC1", "FVR" ]
      
adc_pa = [ "AN0", "AN1", "AN2", "AN3", None, "AN4", None, None ]
adc_pb = [ "AN12", "AN10", "AN8", "AN9", "AN11", "AN13", None, None ]
adc_pc = [ None, None, "AN14", "AN15", "AN16", "AN17", "AN18", "AN19" ]
adc_xx = [ "DAC1", "DAC2", "TEMP", "AN27", "FVR", None, None, None ]



def wcmd(i2c, adr, cmd, data=None):
    if data is None:
        data = []
    idx = 0x40 - len(data)
    data.append(cmd)
    i2c.write_i2c_block_data(adr, idx, data) 

def rcmd(i2c, adr):
    cnt = i2c.read_byte_data(adr, 0x41)
    idx = 0x42
    data = []
    while cnt > 0:
        bcnt = min(cnt, 16)     # 32 causes timeouts
        bdat = i2c.read_i2c_block_data(adr, idx, bcnt) 
        idx += bcnt
        cnt -= bcnt
        data += bdat
    return data

def adc_desc(data):
    if len(data) > len(adc_ch):
        data = [h * 256 + l for h,l in zip(*[iter(data)]*2)]
    for i in range(8):
        desc = (i,)
        for c in (adc_pa, adc_pb, adc_pc, adc_xx):
            pl = "-%5.5s" % c[i]
            if c[i] is None:
                pv = "----"
            else:
                pv = "%04X" % data[adc_ch.index(c[i])]
            desc += (pl, pv)
        print("%X: %s= %s %s= %s %s= %s %s= %s" % desc)

def adc_seqd(info, data):
    if len(data) > len(adc_ch):
        data = [h * 256 + l for h,l in zip(*[iter(data)]*2)]
        data = ["%03X" % _ for _ in data]
    else:
        data = ["%02X" % _ for _ in data]
    print(info, data)



icsp_cmd(ser, b'[Z]', 0)        # tristate MCLR (icsp)

if len(sys.argv) > 1:
    adr = int(sys.argv[1], 0)
else:
    adr = 0x3F

wcmd(i2c2, adr, 0x01)           # get id
data = rcmd(i2c2, adr)
print(data)

# wcmd(i2c2, adr, 0x11, [0x80])   # adc bits
# wcmd(i2c2, adr, 0x13, [20,200])   # adc hold

# for i in range(8):
#    mode = i << 4;
#    wcmd(i2c2, adr, 0x12, [mode])   # adc mode
#    wcmd(i2c2, adr, 0x8A, [5, 0])
#    sleep(0.005)

wcmd(i2c2, adr, 0x11, [0x82])   # adc bits

# print("fake data")
# wcmd(i2c2, adr, 0xF8)           # fake data
# data = rcmd(i2c2, adr)
# adc_desc(data)

wcmd(i2c2, adr, 0x12, [0x00])   # adc mode
wcmd(i2c2, adr, 0x13, [100,10]) # adc hold

print("mode 0 data")
wcmd(i2c2, adr, 0x88)           # sample all
sleep(0.01)
data = rcmd(i2c2, adr)
adc_desc(data)

chans = adc_pb[0:6]
chans = adc_pa[0:4] + adc_pa[5:6] + ["AN27"]

# 0x01 = FVR
# 0x20 = No Hold
# 0x40 = Short Loop

wcmd(i2c2, adr, 0x12, [0x61])   # quick sample
wcmd(i2c2, adr, 0x34, [0x00, 0x00, 0x00])   # wpu

print("--- input")
wcmd(i2c2, adr, 0x31, [0xFF, 0xFF, 0xFF])   # tris
wcmd(i2c2, adr, 0x32, [0x00, 0x00, 0x00])   # lat
for i in chans:
    ch = adc_ch.index(i)

    wcmd(i2c2, adr, 0x8A, [0x10, ch])
    sleep(0.002)
    adc_seqd(i, rcmd(i2c2, adr))

print("-- output high with FVR")
wcmd(i2c2, adr, 0x31, [0xFF, 0xFF, 0x0F])   # tris
wcmd(i2c2, adr, 0x32, [0xFF, 0xFF, 0xFF])   # lat
for i in chans:
    ch = adc_ch.index(i)

    wcmd(i2c2, adr, 0x8B, [0x10, ch])
    sleep(0.002)
    adc_seqd(i, rcmd(i2c2, adr))

print("-- output low with FVR")
wcmd(i2c2, adr, 0x31, [0xFF, 0xFF, 0x0F])   # tris
wcmd(i2c2, adr, 0x32, [0x00, 0x00, 0x00])   # lat
for i in chans:
    ch = adc_ch.index(i)

    wcmd(i2c2, adr, 0x8B, [0x10, ch])
    sleep(0.002)
    adc_seqd(i, rcmd(i2c2, adr))

wcmd(i2c2, adr, 0x12, [0x67])   # quick sample
print("-- output high with DAC2")
wcmd(i2c2, adr, 0x31, [0xFF, 0xFF, 0x0F])   # tris
wcmd(i2c2, adr, 0x32, [0xFF, 0xFF, 0xFF])   # lat
for i in chans:
    ch = adc_ch.index(i)

    wcmd(i2c2, adr, 0x8B, [0x10, ch])
    sleep(0.002)
    adc_seqd(i, rcmd(i2c2, adr))

print("-- output low with DAC2")
wcmd(i2c2, adr, 0x31, [0xFF, 0xFF, 0x0F])   # tris
wcmd(i2c2, adr, 0x32, [0x00, 0x00, 0x00])   # lat
for i in chans:
    ch = adc_ch.index(i)

    wcmd(i2c2, adr, 0x8B, [0x10, ch])
    sleep(0.002)
    adc_seqd(i, rcmd(i2c2, adr))

print("-- output low with pull up")
wcmd(i2c2, adr, 0x31, [0xFF, 0xFF, 0x0F])   # tris
wcmd(i2c2, adr, 0x32, [0x00, 0x00, 0x00])   # lat
wcmd(i2c2, adr, 0x34, [0xFF, 0xFF, 0xFF])   # wpu
for i in chans:
    ch = adc_ch.index(i)

    wcmd(i2c2, adr, 0x8B, [0x10, ch])
    sleep(0.002)
    adc_seqd(i, rcmd(i2c2, adr))


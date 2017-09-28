#!/bin/env python3

# Copyright (C) 2015 Herbert Poetzl

import sys
import serial
import struct

from smbus import SMBus
from time import sleep
from bitarray import bitarray


def leba(bits):
    return bitarray(bits, endian='little')

def bit_split(bits):
    total = bits.length()
    data, mod, val = [], total % 8, 0
    for p in range(0, total, 8):
        seq = bits[p:min(p+8, total)]
        val = ord(seq.tobytes())
        if total - p > 8:
            data.append(val)
    return data, mod, val

def bit_combine(data, mod, val):
    total = len(data) * 8 + (mod if mod > 0 else 8)
    cval = val << ((8 - mod) % 8)
    bits = bitarray(endian='big')
    bits.frombytes(bytes(data + [cval]))
    bits = bits[:total]
    bits.reverse()
    return bits


def jtag_seq(addr, data, mod, val):
    dlen = len(data)
    norm, last = addr[0], addr[1]

    if dlen >= 2:
        car, cdr = data[0], data[1:]
        i2c.write_i2c_block_data(norm, car, cdr)
    elif dlen == 1:
        i2c.write_byte(norm, data[0]) 

    if mod > 0:
        i2c.write_i2c_block_data(last + 1, mod, [val])
    else:
        i2c.write_byte(last, val)

def jtag_rseq(addr, count):
    norm, last = addr[0], addr[1]
    data, mod = [], count % 8

    while count > 8:
        data.append(i2c.read_byte(norm))
        count -= 8

    if mod > 0:
        val = i2c.read_byte_data(last + 1, count)
    else:
        val = i2c.read_byte(last)
    return data, mod, val
    
        
def jtag_tms(bits):
    data, mod, val = bit_split(leba(bits))
    jtag_seq([0x12, 0x12], data, mod, val)

def jtag_tdi(bits, exit=True):
    data, mod, val = bit_split(leba(bits))
    last = 0x16 if exit else 0x1A
    jtag_seq([0x1A, last], data, mod, val)

def jtag_tdo(count, exit=True):
    last = 0x16 if exit else 0x1A
    data, mod, val = jtag_rseq([0x1A, last], count)
    return bit_combine(data, mod, val).to01()


i2c = SMBus(2)


i2c.write_byte(0x38, 0x01)  # TDO_W input
i2c.write_byte(0x3A, 0xFF)  # all pullups

i2c.write_byte(0x39, 0x00) 

jtag_tms("11111111")        # goto reset

jtag_tms("01100")           # goto Shift-IR

# shift in IDCODE [11100000]
jtag_tdi("00000111")

jtag_tms("1100")            # goto Shift-DR

val = jtag_tdo(32)          # read idcode
print(val)

jtag_tms("11111111")        # goto reset

i2c.write_byte(0x39, 0x00) 



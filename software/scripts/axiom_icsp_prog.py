#!/bin/env python3

# Copyright (C) 2015 Herbert Poetzl

import sys
import serial
import struct

from intelhex import IntelHex
from smbus import SMBus
from time import sleep
from axiom_icsp import *

tty = "/dev/ttyPS1"
sel = sys.argv[1] if len(sys.argv) > 1 else "A"
ver = "0.36"

ih = IntelHex(sys.argv[2])
ih.padding = 0xFF

def ih_data(ih, addr, count=32):
    data = []
    mask = 0xFFFF
    for n in range(count):
        l, h = ih[(addr + n)*2], ih[(addr + n)*2 + 1]
        val = (h << 8)|l
        mask &= val
        data.append(val)
    return data, mask

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

i2c0 = SMBus(0)
i2c2 = SMBus(2)

print(icsp_cmd(ser, b'Z'))                      # tristate MCLR (icsp)

pb_ver = "0.30"

try:
    i2c2.read_byte(0x30)
    pb_ver = "0.29"
except:
    pass

try:
    i2c2.read_byte(0x70)
    pb_ver = "0.23"
except:
    pass

print("assuming power board version", pb_ver);

if sel == "A":                                  # take A_!RST low
    if pb_ver == "0.29":
        i2c2.write_byte(0x30, 0x2)              # steer mux
    else:
        i2c2.write_byte(0x70, 0x5)              # steer mux
    ioa = i2c0.read_byte_data(0x23, 0x14)
    i2c0.write_byte_data(0x23, 0x14, ioa&~0x10)

elif sel == "B":                                # take B_!RST low
    if pb_ver == "0.29":
        i2c2.write_byte(0x30, 0x1)              # steer mux
    else:
        i2c2.write_byte(0x70, 0x4)              # steer mux
    iob = i2c0.read_byte_data(0x22, 0x14)
    i2c0.write_byte_data(0x22, 0x14, iob&~0x10)

print(icsp_cmd(ser, b'L'))                      # take MCLR low (icsp)
print(icsp_cmd(ser, b'#', 9))                   # reset checksum
print(icsp_enter_lvp(ser))                      # enter LVP

print("reading config memory ...")

icsp_load_conf(ser)
conf = icsp_read_data(ser, 0x11)
print([hex(_) for _ in conf])

prog = False
if conf[5] == 0x2000 and conf[6] == 0x305b:
    print("pic16f1718 found.")
    prog = True

if conf[5] == 0x2004 and conf[6] == 0x3042:
    print("pic16f1708 found.")
    prog = True

if prog:
    icsp_reset_addr(ser) 
    icsp_load_conf(ser)
    # icsp_row_erase(ser)
    # sleep(0.005)
    # icsp_load_conf(ser)
    icsp_bulk_erase(ser)
    sleep(0.010)
    icsp_reset_addr(ser) 

    print("programming code memory ...")
    for addr in range(0, 0x4000, 0x20):
        data, mask = ih_data(ih, addr)

        first = addr == 0
        if mask != 0xFFFF:
            icsp_loadn(ser, data, first)
            icsp_iprog(ser)
            # print(addr, data)
        else:
            if first:
                icsp_advance(ser, 31)
            else:
                icsp_advance(ser, 32)

        print("%04X/%04X" % (addr, 0x4000), end="\r");

    icsp_reset_addr(ser) 

#   print("verifying code memory ...")
#   for addr in range(0, 0x4000, 0x20):
#       data, mask = ih_data(ih, addr)
#       data = [_ & 0x3FFF for _ in data]
#       read = icsp_read_data(ser, 0x20)
#
#       if read != data:
#           print("mismatch @%04X:" % (addr))
#           print("wrote\t", [hex(_) for _ in data])
#           print("read\t", [hex(_) for _ in read])
#
#       print("%04X/%04X" % (addr, 0x4000), end="\r");
 
    print("programming user id ...")
    data, mask = ih_data(ih, 0x8000, 4)         # user id
    print([hex(_) for _ in data])

    icsp_load_conf(ser)
    icsp_loadn(ser, data[0:4], True)
    icsp_iprog(ser, delay=5.0)                  # internal programming

    print("verifying user id ...")
    data = [_ & 0x3FFF for _ in data]

    icsp_load_conf(ser)
    read = icsp_read_data(ser, 0x4)

    if read != data:
        print("mismatch:\t", [hex(_) for _ in read])

    print("programming config words ...")
    data, mask = ih_data(ih, 0x8007, 2)         # config words
    print([hex(_) for _ in data])

    icsp_load_conf(ser)
    icsp_load_data(ser, data[0], 0x7)
    icsp_iprog(ser, delay=5.0)                  # internal programming
    icsp_load_data(ser, data[1], 1)
    icsp_iprog(ser, delay=5.0)                  # internal programming

    print("verifying config words ...")
    data = [_ & 0x3FFF for _ in data]

    icsp_load_conf(ser)
    icsp_advance(ser, 0x7)
    read = icsp_read_data(ser, 0x2)

    if read != data:
        print("mismatch:\t", [hex(_) for _ in read])

else:
    print("pic16f1718 not found")

print(icsp_cmd(ser, b'#', 9))                   # retrieve checksum
print(icsp_cmd(ser, b'Z'))                      # tristate MCLK (icsp)

if pb_ver == "0.29":
    print("mux = 0x%02x" % i2c2.read_byte(0x30))

if sel == "A":                                  # bring A_!RST high again
    i2c0.write_byte_data(0x23, 0x14, ioa|0x10)
elif sel == "B":                                # bring B_!RST high again
    i2c0.write_byte_data(0x22, 0x14, iob|0x10)
elif sel == "P":
    pass
else:
    if pb_ver == "0.29":
        i2c2.write_byte(0x30, 0x0)              # disable mux
    else:
        i2c2.write_byte(0x70, 0x0)              # disable mux



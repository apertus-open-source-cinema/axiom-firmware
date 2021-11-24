#!/bin/env python3

# SPDX-FileCopyrightText: © 2016 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

import os
import sys
import serial
import struct
import random

from smbus import SMBus
from time import sleep
from axiom_icsp import *


tty = "/dev/ttyPS1"
delay = 0.001

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

i2c = SMBus(2)

print(icsp_cmd(ser, b'Z'))                      # tristate MCLR (icsp)

data = [ _ ^ 0xFF for _ in range(256)]

if len(sys.argv) < 2:
    addr = 0x10
else:
    addr = int(sys.argv[1], 0)


for i in range(16):
    index = random.randrange(0, 224)
    count = random.randrange(0, 32)

    try:
        # read with cmd/idx
        read = i2c.read_i2c_block_data(addr, index, count)
    except OSError as e:
        print(e)

    sleep(delay)

    if read != data[index:index+count]:
        print(read, data[index:index+count])

    index = random.randrange(0, 224)
    count = random.randrange(0, 32)

    seq = [random.randrange(0, 255) for _ in range(count)]

    try:
        # write block data
        i2c.write_i2c_block_data(addr, index, seq)
    except OSError as e:
        print(e)

    sleep(delay)

    for i in range(index, index+count):
        data[i] = seq[i - index]

exit(0)



try:
    # zero byte write
    i2c.write_quick(addr)
except OSError as e:
    error[0] = e

sleep(delay)

try:
    # single byte read
    read[0] = i2c.read_byte(addr)
except OSError as e:
    error[1] = e

sleep(delay)

try:
    # single byte write
    i2c.write_byte(addr, data[0])
except OSError as e:
    error[2] = e

sleep(delay)

try:
    # read with cmd/idx
    read[1] = i2c.read_byte_data(addr, cmd)
except OSError as e:
    error[3] = e

sleep(delay)

try:
    # write with cmd/idx
    i2c.write_byte_data(addr, cmd, data[0])
except OSError as e:
    error[4] = e

sleep(delay)

try:
    # read block data
    read[2] = i2c.read_i2c_block_data(addr, cmd, cnt)
except OSError as e:
    error[5] = e

sleep(delay)

try:
    # write block data
    i2c.write_i2c_block_data(addr, cmd, data)
except OSError as e:
    error[6] = e

sleep(delay)

try:
    # general call 
    i2c.write_byte(0x00, 0x06)
except OSError as e:
    error[7] = e

sleep(delay)

try:
    # general call w. data
    i2c.write_byte_data(0x00, 0x01, data[1])
except OSError as e:
    error[8] = e

sleep(delay)


print(read)
errno = [_.args[0] if _ is not None else 0 for _ in error]

print([os.strerror(_) for _ in errno])

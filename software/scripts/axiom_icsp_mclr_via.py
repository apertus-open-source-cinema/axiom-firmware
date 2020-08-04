#!/bin/env python3

# Copyright (C) 2017 Herbert Poetzl

import sys
import serial
import struct

from intelhex import IntelHex
from smbus import SMBus
from time import sleep
from axiom_icsp import *
from axiom_via import *

tty = "/dev/ttyPS1"

sel = sys.argv[1]

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

icsp_cmd(ser, b'[L1000.Z]', 0)
sleep(0.2)

via_port(i2c, via_invp(sel))



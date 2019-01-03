#!/bin/env python3

# Copyright (C) 2015 Herbert Poetzl

import sys
#import serial
#import struct

from smbus import SMBus
#from time import sleep
from bitarray import bitarray
from jtag import *
from mxo2 import *



i2c = SMBus(2)
jtag = JTag(i2c)

jtag.on()
jtag.reset()

idcode = jtag.cmdout(IDCODE, 32)
dev = DEVID[idcode][0]
print("found %s [%s]" % (dev, idcode))

jtag.cmdin(ISC_ENABLE, h2b("08"))
status(jtag)

featrow = jtag.cmdout(LSC_READ_FEATURE, 64)
print("featrow = %s [%s]" % (b2h(featrow), featrow))
feabits = jtag.cmdout(LSC_READ_FEABITS, 16)
print("feabits = %s [%s]" % (b2h(feabits), feabits))

status(jtag)

if len(sys.argv) > 2:
    feabits = h2b(sys.argv[2])

if len(sys.argv) > 1:
    featrow = h2b(sys.argv[1])

    jtag.cmdin(ISC_ERASE, h2b("02")) # erase feature sector
    wnbusy(jtag)

    jtag.cmdin(LSC_PROG_FEATURE, featrow)
    status(jtag)

    jtag.cmdin(LSC_PROG_FEABITS, feabits)
    status(jtag)

featrow = jtag.cmdout(LSC_READ_FEATURE, 64)
print("featrow = %s [%s]" % (b2h(featrow), featrow))
feabits = jtag.cmdout(LSC_READ_FEABITS, 16)
print("feabits = %s [%s]" % (b2h(feabits), feabits))
status(jtag)

jtag.cmd(ISC_DISABLE)
status(jtag)

jtag.reset()
jtag.off()



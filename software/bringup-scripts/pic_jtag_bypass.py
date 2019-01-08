#!/bin/env python3

# Copyright (C) 2016 Herbert Poetzl

import sys

from smbus import SMBus
from bitarray import bitarray
from jtag import *
from mxo2 import *



i2c = SMBus(2)
jtag = JTag(i2c)

jtag.on()
jtag.reset()

idcode = jtag.cmdout(IDCODE, 32)
dev, cfg, ufm, _ = DEVID[idcode]
print("found %s [%s]" % (dev, idcode))

seq = jtag.cmdshift(BYPASS, "01001100011100001111")
print(seq)


jtag.reset()
jtag.off()



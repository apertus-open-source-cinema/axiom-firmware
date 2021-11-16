#!/bin/env python3

# Copyright (C) 2015 Herbert Poetzl

import sys

from smbus import SMBus
from bitarray import bitarray
from axiom_jtag import *
from axiom_mxo2 import *



i2c = SMBus(2)
jtag = JTag(i2c, base=0x40, debug=False)

jtag.on()
jtag.reset()

idcode = jtag.cmdout(IDCODE, 32)
dev = DEVID[idcode][0]
print("found %s [%s]" % (dev, idcode))

usercode = jtag.cmdout(USERCODE, 32)
print("usercode %s [%s]" % (b2h(usercode), usercode))

traceid = jtag.cmdout(UIDCODE_PUB, 64)
print("traceid %s:%s [%s:%s]" % 
    (b2h(traceid[:8]), b2h(traceid[8:]),
    traceid[:8], traceid[8:]))

jtag.reset()
jtag.off()



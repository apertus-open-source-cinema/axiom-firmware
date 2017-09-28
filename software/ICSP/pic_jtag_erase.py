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
dev = DEVID[idcode]
cfg, ufm = DEVFP[idcode]
print("found %s [%s]" % (dev, idcode))

print("erasing flash ...")
jtag.cmdin(ISC_ENABLE, h2b("08"))
jtag.cmdin(ISC_ERASE, h2b("0F"))
wnbusy(jtag)
status(jtag)

jtag.cmd(ISC_DISABLE)
jtag.cmd(BYPASS)
status(jtag)

jtag.reset()
jtag.off()



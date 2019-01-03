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

jtag.cmdin(ISC_ENABLE, h2b("08"))
status(jtag)

print("dumping config memory ...")
jtag.cmdin(LSC_INIT_ADDRESS, h2b("04"))
jtag.cmd(LSC_READ_INCR_NV)
for page in range(cfg):
    row = jtag.tdo(128)
    jtag.idle(2)
    print("%04X: %s [%s]" % (page, b2h(row), row))

print("dumping user memory ...")
jtag.cmd(LSC_INIT_ADDR_UFM)
jtag.cmd(LSC_READ_INCR_NV)
for page in range(ufm):
    row = jtag.tdo(128)
    jtag.idle(2)
    print("%04X: %s [%s]" % (page, b2h(row), row))

jtag.cmd(ISC_DISABLE)
status(jtag)

jtag.reset()
jtag.off()



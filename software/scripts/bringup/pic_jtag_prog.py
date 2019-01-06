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

usercode = jtag.cmdout(USERCODE, 32)
print("usercode %s [%s]" % (b2h(usercode), usercode))

print("enable flash ...")
jtag.cmdin(ISC_ENABLE, h2b("00"))
jtag.cmdin(ISC_ERASE, h2b("01"))
jtag.cmd(BYPASS)
status(jtag)

jtag.cmdin(ISC_ENABLE, h2b("08"))
status(jtag)

print("erasing config memory ...")
jtag.cmdin(ISC_ERASE, h2b("04"))
wnbusy(jtag)
status(jtag)

print("flashing config memory ...")
jtag.cmdin(LSC_INIT_ADDRESS, h2b("04"))

with open(sys.argv[1]) as f:
    for page in range(cfg):
        row = h2b(f.readline().strip())
        print("page %d/%d" % (page, cfg), end="\r")
        # print("%04X: %s [%s]" % (page, b2h(row), row))
        jtag.cmdin(LSC_PROG_INCR_NV, row)
        wnbusy(jtag, debug=False)

status(jtag)

print("erasing user memory ...")
jtag.cmdin(ISC_ERASE, h2b("08"))
wnbusy(jtag)
status(jtag)

print("flashing user memory ...")
jtag.cmd(LSC_INIT_ADDR_UFM)
        
with open(sys.argv[2]) as f:
    for page in range(ufm):
        row = h2b(f.readline().strip())
        print("page %d/%d" % (page, ufm), end="\r")
        # print("%04X: %s [%s]" % (page, b2h(row), row))
        jtag.cmdin(LSC_PROG_INCR_NV, row)
        wnbusy(jtag, debug=False)

status(jtag)

if usercode != "0"*8:
    print("flashing usercode ...")
    # jtag.cmdin(ISC_PROGRAM_USERCODE, usercode)
    wnbusy(jtag)

jtag.cmd(ISC_PROGRAM_DONE)
wnbusy(jtag)

jtag.cmd(BYPASS)

jtag.cmd(ISC_DISABLE)
jtag.cmd(BYPASS)
status(jtag)

jtag.reset()
jtag.off()



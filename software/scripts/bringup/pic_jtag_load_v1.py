#!/bin/env python3

# Copyright (C) 2016 Herbert Poetzl

import sys

from smbus import SMBus
from bitarray import bitarray
from jtag import *
from mxo2 import *



i2c = SMBus(2)
jtag = JTag(i2c,debug=True)

jtag.on()
jtag.reset()

idcode = jtag.cmdout(IDCODE, 32)
dev, cfg, ufm = DEVID[idcode]
print("found %s [%s]" % (dev, idcode))

print("enable flash ...")
jtag.cmdin(ISC_ENABLE, h2b("00"))
jtag.cmdin(ISC_ERASE, h2b("01"))
jtag.cmd(BYPASS)
status(jtag)

jtag.cmdin(LSC_INIT_ADDRESS, h2b("01"))

if len(sys.argv) > 2:

    print("loading cfg sram ...")
    jtag.sir(LSC_BITSTREAM_BURST)
    with open(sys.argv[1]) as f:
        for page in range(cfg):
            row = h2b(f.readline().strip())
            print("page %d/%d" % (page, cfg), end="\r")
            # print("%04X: %s [%s]" % (page, b2h(row), row))
            jtag.tdi(row, exit=True)


    print("loading ufm sram ...")
    with open(sys.argv[2]) as f:
        for page in range(ufm):
            row = h2b(f.readline().strip())
            print("page %d/%d" % (page, ufm), end="\r")
            # print("%04X: %s [%s]" % (page, b2h(row), row))
            jtag.tdi(row, exit=True)

else:

    print("loading sram ...")
    jtag.sir(LSC_BITSTREAM_BURST)
    jtag.tdi("", exit=True)
    with open(sys.argv[1]) as f:
        for page in range(cfg+ufm):
            row = h2b(f.readline().strip())
            if row == "":
                break
            print("page %d/%d" % (page, cfg+ufm), end="\r")
            # print("%04X: %s [%s]" % (page, b2h(row), row))
            jtag.tdi(row, exit=True)

#    with open(sys.argv[1], "rb") as f:
#        data = f.read()
#        bits = bitarray(endian='big')
#        bits.frombytes(data)
#        while len(bits) > 0:
#            chunk = bits[:128]
#            bits = bits[128:]
#            print(chunk)
            # jtag.tdi(chunk, exit=True)

jtag.idle(100)
status(jtag)

jtag.cmd(ISC_DISABLE)
jtag.cmd(BYPASS)
status(jtag)

jtag.reset()
jtag.off()



#!/bin/env python3

# Copyright (C) 2016 Herbert Poetzl

import sys
import os

from smbus import SMBus
from bitarray import bitarray
from jtag import *
from mxo2 import *
from time import time




i2c = SMBus(2)
jtag = JTag(i2c)

jtag.on()
jtag.reset()

idcode = jtag.cmdout(IDCODE, 32)
dev, cfg, ufm, cells = DEVID[idcode]
print("found %s [%s] {%d}" % (dev, idcode, cells))

traceid = jtag.cmdout(UIDCODE_PUB, 64)
print("traceid %s:%s [%s:%s]" % 
    (b2h(traceid[:8]), b2h(traceid[8:]),
    traceid[:8], traceid[8:]))

now = int(time())
for idx in range(100):
    path = "{:s}-{:s}-{:d}.extest".format(dev, b2h(traceid), idx)
    if not os.path.isfile(path):
        break
        
print("writing data to {:s}".format(path))
f = open(path, 'w')
sys.stdout = f

jtag.cmdshift(EXTEST, "1"*cells, 0)
for b in range(cells + 1):
    seq = "".join(["0" if _==b else "1" for _ in range(cells)])
    seq = jtag.cmdshift(EXTEST, seq, 0)
    print("{:3d} {:s}".format(cells-b, seq))

print("\n")
jtag.cmdshift(EXTEST, "0"*cells, 0)
for b in range(cells + 1):
    seq = "".join(["1" if _==b else "0" for _ in range(cells)])
    seq = jtag.cmdshift(EXTEST, seq, 0)
    print("{:3d} {:s}".format(cells-b, seq))

jtag.reset()
jtag.off()



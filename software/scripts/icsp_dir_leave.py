#!/bin/env python3

import sys

from smbus import SMBus


i2c2 = SMBus(2)

def wcmd(i2c, adr, cmd, data=None):
    if data is None:
        data = []
    idx = 0x40 - len(data)
    data.append(cmd)
    i2c.write_i2c_block_data(adr, idx, data) 

wcmd(i2c2, int(sys.argv[1], 0), 0x02)


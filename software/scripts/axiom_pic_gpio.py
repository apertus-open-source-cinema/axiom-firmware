#!/bin/env python3

# Copyright (C) 2016 Herbert Poetzl

import sys
from smbus import SMBus
from time import sleep

def gpio_probe(i2c):
    ver = "0.23"
    return ver

def gpio_init(i2c, ver):
    if ver == "0.23":
        pass

def gpio_names(ver, sel, addr):
    ret = [ "???" ] * 16
    if ver == "0.23":
        if sel == 'A':
            if addr == 0x30:
                ret = [ "W_I2C_EN", "S_I2C_EN",
                        "#W_RESET", "SDO_W",
                        "SCK_W", "#SS_W",
                        "BANK13_SE_0", "ra7" ]
            elif addr == 0x34:
                ret = [ "INITN_W", "rb1",
                        "DONE_W", "SDI_W",
                        "SN_W", "PB22B_W",
                        "rb6", "rb7" ]
            elif addr == 0x38:
                ret = [ "TDO_W", "TDI_W",
                        "TCK_W", "TMS_W",
                        "PCIE_SCL", "PCIE_SDA",
                        "JTAGENB_W", "PROGRAMN_W" ]
        elif sel == 'B':
            if addr == 0x30:
                ret = [ "E_I2C_EN", "N_I2C_EN",
                        "#E_RESET", "SDO_E",
                        "SCK_E", "#SS_E",
                        "JX1_SE_0", "ra7" ]
            elif addr == 0x34:
                ret = [ "INITN_E", "rb1",
                        "DONE_E", "SDI_E",
                        "SN_E", "PB22B_E",
                        "rb6", "rb7" ]
            elif addr == 0x38:
                ret = [ "TDO_E", "TDI_E",
                        "TCK_E", "TMS_E",
                        "IO_SCL", "IO_SDA",
                        "JTAGENB_E", "PROGRAMN_E" ]
    return ret


i2c2 = SMBus(2)

# ver = gpio_probe(i2c0)
ver = "0.23"
if len(sys.argv) > 1:
    if sys.argv[1] == "init":
        # gpio_init(i2c, ver)
        pass

mux = i2c2.read_byte(0x70)
if mux == 4:
    sel = 'B'
elif mux == 5:
    sel = 'A'

data, names = {}, {}
for addr in [ 0x30, 0x34, 0x38 ]:
    names[addr,'A'] = gpio_names(ver, 'A', addr)
    names[addr,'B'] = gpio_names(ver, 'B', addr)
    for reg in (0x00, 0x01, 0x02, 0x03):
        data[addr, reg] = i2c2.read_byte(addr + reg)

for bit in range(8):
    for addr, port in [ (0x30,'A'), (0x34,'B'), (0x38,'C') ]:
        name = names[addr,sel][bit]
        mask = 1 << bit
        end = '\n' if addr == 0x38 else '\t'
        typ = 'I' if data[addr, 0x00] & mask else 'O'
        pup = '^' if data[addr, 0x02] & mask else ' '
        lat = (data[addr, 0x01] >> bit) & 1
        val = (data[addr, 0x03] >> bit) & 1
        print("[%s%d] %-12.12s %c%d+%d%c" % (port, bit, name, typ, val, lat, pup), end=end)
print("")



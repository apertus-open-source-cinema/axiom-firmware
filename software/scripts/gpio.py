#!/bin/env python3

# Copyright (C) 2016 Herbert Poetzl

import sys
from smbus import SMBus
from time import sleep


def wait_enter(msg="Continue?"):
    try:
        input(msg)
    except SyntaxError:
        pass

def gpio_probe(i2c):
    ver = "0.23"
    return ver

def gpio_init(i2c, ver):
    if ver == "0.23":
        i2c.write_byte_data(0x20, 0x00, 0b01010101)   # PG in, EN out
        i2c.write_byte_data(0x20, 0x01, 0b11111001)   # PG in, EN out
        i2c.write_byte_data(0x20, 0x0c, 0b11111111)   # all pullups
        i2c.write_byte_data(0x20, 0x0d, 0b11111111)   # all pullups

        i2c.write_byte_data(0x21, 0x00, 0b01010101)   # PG in, EN out
        i2c.write_byte_data(0x21, 0x01, 0b01010101)   # PG in, EN out
        i2c.write_byte_data(0x21, 0x0c, 0b11111111)   # all pullups
        i2c.write_byte_data(0x21, 0x0d, 0b11111111)   # all pullups
    
        i2c.write_byte_data(0x22, 0x00, 0b10100101)   # CD in, RST out
        i2c.write_byte_data(0x22, 0x01, 0b11000011)   # EN out
        i2c.write_byte_data(0x22, 0x0c, 0b11111111)   # all pullups
        i2c.write_byte_data(0x22, 0x0d, 0b11111111)   # all pullups

        i2c.write_byte_data(0x23, 0x00, 0b11100101)   # RST out
        i2c.write_byte_data(0x23, 0x01, 0b11000011)   # EN out
        i2c.write_byte_data(0x23, 0x0c, 0b11111111)   # all pullups
        i2c.write_byte_data(0x23, 0x0d, 0b11111111)   # all pullups

def gpio_test(i2c, ver):
    if ver == "0.23":
        units = [   \
            (0x21, 0, 1, 0, "Sensor NE"),
            (0x21, 0, 3, 2, "Sensor NN"),
            (0x21, 0, 5, 4, "Sensor NW"),
            (0x21, 0, 7, 6, "Sensor WW"),
            (0x21, 1, 1, 0, "Sensor SW"),
            (0x21, 1, 3, 2, "Sensor SS"),
            (0x21, 1, 5, 4, "Sensor SE"),
            (0x21, 1, 7, 6, "Sensor EE"),
            (0x22, 0, 1, 0, "IO East"),
            (0x22, 0, 3, 2, "RF East"),
            (0x23, 0, 1, 0, "IO West"),
            (0x23, 0, 3, 2, "RF West"),
            (0x20, 0, 1, 0, "MX North"),
            (0x20, 0, 3, 2, "MC North"),
            (0x20, 0, 5, 4, "FPGA VIO"),
            (0x20, 0, 7, 6, "MC South"),
            (0x20, 1, 1, 0, "MX South"),
            (0x22, 1, 2,-1, "East SPI"),
            (0x22, 1, 3,-1, "North I2C"),
            (0x22, 1, 4,-1, "North SPI"),
            (0x22, 1, 5,-1, "East I2C"),
            (0x23, 1, 2,-1, "West SPI"),
            (0x23, 1, 3,-1, "South I2C"),
            (0x23, 1, 4,-1, "South SPI"),
            (0x23, 1, 5,-1, "West I2C") ]

        for addr, port, en, pg, label in units:
            try:
                names = gpio_names(ver, addr)
                wait_enter("%s [%s]?" % (label, names[port][en]))
                i2c.write_byte_data(addr, 0x14 + port, 1 << en)  
                sleep(5.2)
                if pg >= 0:
                    val = i2c.read_byte_data(addr, 0x12 + port)
                    val = (val >> pg) & 1
                    print("power good = %d" % (val))
                sleep(0.2)
                i2c.write_byte_data(addr, 0x14 + port, 0)  
                
            except:
                return 1
    return 0


def gpio_names(ver, addr):
    ret = [ "???" ] * 16
    if ver == "0.23":
        if addr == 0x20:
            ret = ([ "MXN_PG", "MXN_EN", "MCN_PG", "MCN_EN",
                     "VIO_PG", "VIO_EN", "MCS_PG", "MCS_EN" ],
                   [ "MXS_PG", "MXS_EN", "CNW_EN", "u20#b3",
                     "u20#b4", "u20#b5", "u20#b6", "u20#b7" ])
        elif addr == 0x21:
            ret = ([ "NE_PG", "NE_EN", "NN_PG", "NN_EN",
                     "NW_PG", "NW_EN", "WW_PG", "WW_EN" ],
                   [ "SW_PG", "SW_EN", "SS_PG", "SS_EN",
                     "SE_PG", "SE_EN", "EE_PG", "EE_EN" ])
        elif addr == 0x22:
            ret = ([ "IOE_PG", "IOE_EN", "RFE_PG", "RFE_EN",
                     "B_#RST", "u22#a5", "CSE_EN", "CD'" ],
                   [ "u22#b0", "u22#b1", "E_SPI_EN", "N_I2C_EN",
                     "N_SPI_EN", "E_I2C_EN", "u22#b6", "u22#b7" ])
        elif addr == 0x23:
            ret = ([ "IOW_PG", "IOW_EN", "RFW_PG", "RFW_EN",
                     "A_#RST", "u23#a5", "u23#a6", "u23#a7" ],
                   [ "u23#b0", "u23#b1", "JTAG_EN", "S_I2C_EN",
                     "S_SPI_EN", "W_I2C_EN", "u23#b6", "u23#b7" ])
    return ret


i2c = SMBus(0)

ver = gpio_probe(i2c)
if len(sys.argv) > 1:
    if sys.argv[1] == "init":
        gpio_init(i2c, ver)
    if sys.argv[1] == "test":
        if gpio_test(i2c, ver) > 0:
            print("\nTest cancelled.")
        exit(0)

data, names = {}, {}
for addr in [ 0x20, 0x21, 0x22, 0x23 ]:
    names[addr,0], names[addr,1] = gpio_names(ver, addr)
    for port in (0, 1):
        for reg in (0x00, 0x02, 0x0C, 0x12, 0x14):
            data[addr, port, reg] = i2c.read_byte_data(addr, reg + port)

for port in (0, 1):
    for bit in range(8):
        for addr in [ 0x20, 0x21, 0x22, 0x23 ]:
            name = names[addr, port][bit]
            mask = 1 << bit
            pid = ('a', 'b')[port]
            end = '\n' if addr == 0x23 else '\t'
            typ = 'I' if data[addr, port, 0x00] & mask else 'O'
            pol = '-' if data[addr, port, 0x02] & mask else '+'
            pup = '^' if data[addr, port, 0x0C] & mask else ' '
            val = (data[addr, port, 0x12] >> bit) & 1
            lat = (data[addr, port, 0x14] >> bit) & 1
            print("[%02X%c%d] %-9.9s %c%d%c%d%c" % (addr, pid, bit, name, typ, val, pol, lat, pup), end=end)
    print("")



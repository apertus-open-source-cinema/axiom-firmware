#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir


. ./i2c0.func 

# enable VIO

i2c0_bit_set 0x20 0x14 5


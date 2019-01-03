#!/bin/bash

./power_init.sh
./power_on.sh
./fclk_init.sh

./gpio.py init

. i2c0.func

i2c0_bit_clr 0x22 0x15 7
sleep 0.1
i2c0_bit_set 0x22 0x15 7

cat icsp.bit >/dev/xdevcfg

echo "Z<" >/dev/ttyPS1

# i2cdetect -y -a -r 2

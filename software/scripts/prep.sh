#!/bin/bash

./power_init.sh
./power_on.sh
./fclk_init.sh

cat icsp.bit >/dev/xdevcfg

# ./icsp_off.py /dev/ttyPS1

# i2cdetect -y -a -r 2

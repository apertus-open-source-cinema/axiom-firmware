#!/bin/bash

./../power_init.sh
./../power_on.sh
./../fclk_init.sh
./../gpio.py init

cat icsp.bit >/dev/xdevcfg
sleep 0.2

./icsp_high.py /dev/ttyPS1
./icsp_pclk_off.py /dev/ttyPS1

# i2cdetect -y -a -r 2

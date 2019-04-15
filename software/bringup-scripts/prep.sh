#!/bin/bash

./../scripts/power_init.sh
./../scripts/power_on.sh
./../scripts/fclk_init.sh

echo icsp.bin > /sys/class/fpga_manager/fpga0/firmware

# ./icsp_off.py /dev/ttyPS1

# i2cdetect -y -a -r 2

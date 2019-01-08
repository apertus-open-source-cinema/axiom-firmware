#!/bin/bash

./../power_init.sh
./../power_on.sh
./../fclk_init.sh

echo icsp.bin > /sys/class/fpga_manager/fpga0/firmware

# ./icsp_off.py /dev/ttyPS1

# i2cdetect -y -a -r 2

#!/bin/bash

./../power_init.sh
./../power_on.sh
./../fclk_init.sh
./../gpio.py init

echo icsp.bin > /sys/class/fpga_manager/fpga0/firmware
sleep 0.2

./icsp_high.py /dev/ttyPS1
./icsp_pclk_off.py /dev/ttyPS1

# i2cdetect -y -a -r 2

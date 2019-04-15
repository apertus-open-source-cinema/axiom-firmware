#!/bin/bash

./../scripts/power_init.sh
./../scripts/power_on.sh
./../scripts/fclk_init.sh
./../scripts/gpio.py init

echo icsp.bin > /sys/class/fpga_manager/fpga0/firmware
sleep 0.2

./icsp_high.py /dev/ttyPS1
./icsp_pclk_off.py /dev/ttyPS1

# i2cdetect -y -a -r 2

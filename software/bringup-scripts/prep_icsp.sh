#!/bin/bash

./../scripts/power_init.sh
./../scripts/power_on.sh
./../scripts/fclk_init.sh

./../scripts/gpio.py init

. ../scripts/i2c0.func

i2c0_bit_clr 0x22 0x15 7
sleep 0.1
i2c0_bit_set 0x22 0x15 7

echo icsp.bin > /sys/class/fpga_manager/fpga0/firmware

echo "Z<" >/dev/ttyPS1

# i2cdetect -y -a -r 2

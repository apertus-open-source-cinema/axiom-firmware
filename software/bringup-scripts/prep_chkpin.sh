#!/bin/bash

./../scripts/power_init.sh
./../scripts/power_on.sh
./../scripts/fclk_init.sh
./../scripts/gpio.py init

echo check_spkfan.bit > /sys/class/fpga_manager/fpga0/firmware
sleep 0.2

./rf_disable.sh


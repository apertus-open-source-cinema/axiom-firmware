#!/bin/bash

./../power_init.sh
./../power_on.sh
./../fclk_init.sh
./../gpio.py init

echo check_spkfan.bit > /sys/class/fpga_manager/fpga0/firmware
sleep 0.2

./rf_disable.sh


#!/bin/bash

axiom_power_init.sh
axiom_power_on.sh
axiom_fclk_init.sh
axiom_gpio.py init

echo icsp.bin > /sys/class/fpga_manager/fpga0/firmware
sleep 0.2

axiom_icsp_high.py /dev/ttyPS1
axiom_icsp_pclk_off.py /dev/ttyPS1

# i2cdetect -y -a -r 2

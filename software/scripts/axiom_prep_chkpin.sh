#!/bin/bash

axiom_power_init.sh
axiom_power_on.sh
axiom_fclk_init.sh
axiom_gpio.py init

echo check_spkfan.bit > /sys/class/fpga_manager/fpga0/firmware
sleep 0.2

axiom_rf_disable.sh

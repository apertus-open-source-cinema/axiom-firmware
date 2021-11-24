#!/bin/bash

# SPDX-FileCopyrightText: © 2017 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

axiom_power_init.sh
axiom_power_on.sh
axiom_fclk_init.sh
axiom_gpio.py init

echo check_spkfan.bit > /sys/class/fpga_manager/fpga0/firmware
sleep 0.2

axiom_rf_disable.sh

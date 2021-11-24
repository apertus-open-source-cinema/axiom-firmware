#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

axiom_power_init.sh
axiom_power_on.sh
axiom_fclk_init.sh

echo icsp.bin > /sys/class/fpga_manager/fpga0/firmware

# ./icsp_off.py /dev/ttyPS1

# i2cdetect -y -a -r 2

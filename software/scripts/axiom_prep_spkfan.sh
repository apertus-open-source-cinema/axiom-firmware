#!/bin/bash

# SPDX-FileCopyrightText: © 2016 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

SCRIPT_PATH=$(dirname $(realpath $0))    # change into script dir


axiom_power_init.sh
axiom_power_on.sh
axiom_fclk_init.sh

echo icsp.bin > /sys/class/fpga_manager/fpga0/firmware

echo "Z<" >/dev/ttyPS1

axiom_rf_sel.py B
axiom_pic_jtag_load.py $SCRIPT_PATH/pass_spkfan.cfg $SCRIPT_PATH/pass_spkfan.ufm

echo check_spkfan.bit > /sys/class/fpga_manager/fpga0/firmware
axiom_spkfan_init.sh

echo 1 >/sys/class/gpio/gpio962/value


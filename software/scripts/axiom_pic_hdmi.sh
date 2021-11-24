#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

axiom_power_init.sh
axiom_icsp_off.py /dev/ttyPS1
sleep 1
axiom_power_on.sh
sleep 0.5

i2cset -y 0 0x23 0x14 0xFF	# reset pic
i2cset -y 2 0x70 0x0 0x5	# RFW
i2cset -y 0 0x23 0x14 0x1F	# take pic out of reset
sleep 0.5
i2cdetect -r -y -a 2

# axiom_pic_jtag_hdmi.sh

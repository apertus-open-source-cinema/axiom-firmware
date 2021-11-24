#!/bin/bash

# SPDX-FileCopyrightText: © 2016 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

axiom_snap -e 9.2ms -z

chr_reg 0 0x0

chr_reg 2 0x200
chr_reg 3 0x64

chr_reg 4 0x5048
chr_reg 5 0x7060
chr_reg 6 0x4530
chr_reg 7 0x7040

chr_reg 6 0x857A	# green
chr_reg 7 0x3025	# green

chr_reg 8 0xB5AE	# blue
chr_reg 9 0x5040	# blue

chr_reg 8 0x3F39	# pink
chr_reg 9 0x5040	# pink

chr_reg 4 0x4745	# orange
chr_reg 5 0x6050	# orange


#set sensor window to 16:9
axiom_cmv_reg 1 0x0870
axiom_rmem_conf.sh 64 0
axiom_cmv_reg 2 456
axiom_gamma_conf.sh 0.8
axiom_mat4_conf.sh 0 0 0 0  0 0 0 1.3  0 0.42 0.42 0  1 0 0 0

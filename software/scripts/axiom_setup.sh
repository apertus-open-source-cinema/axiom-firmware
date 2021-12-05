#!/bin/bash

# SPDX-FileCopyrightText: © 2016 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

MODE=${1:-normal}

# devmem 0x80010018 32 0x00000

# axiom_gen_init.sh 1080p60
# axiom_gen_init.sh 1080p50
# axiom_gen_init.sh 1080p30
# axiom_gen_init.sh 1080p24

[ "$MODE" == "normal" ] && axiom_gen_init.sh SHOGUN
[ "$MODE" == "raw" ] && axiom_gen_init_hdmi.sh 1080p60

axiom_data_init.sh
axiom_rmem_conf.sh
axiom_wmem_conf.sh
# axiom_linear_conf.sh 1.3 0.0
[ "$MODE" == "normal" ] && axiom_linear_conf.sh 1.0 0.0
# axiom_linear_conf.sh 1.6 0.0
# ./remap_conf.sh $DISP
# axiom_gamma_conf.sh 1
axiom_gamma_conf.sh 0.8

# axiom_mat4_conf.sh  1 0 0 0  0 1 0 0  0 0 1 0  0 0 0 1  0 0 0 0
# axiom_mat4_conf.sh 1 0 0 0  0 0.5 0.5 0  0 0.5 0.5 0  0 0 0 1  0 0 0 0
# axiom_mat4_conf.sh 0.3 0.3 0.3 0.3  0 0 0 1  0 0.5 0.5 0  1 0 0 0
axiom_mat4_conf.sh 0.3 0.3 0.3 0.3  0 0 0 1  0 0.42 0.42 0  1 0 0 0

[ "$MODE" == "normal" ] && axiom_scn_reg 31 3
[ "$MODE" == "normal" ] && axiom_scn_reg 31 1

[ "$MODE" == "raw" ] && axiom_scn_reg 31 0x4000
[ "$MODE" == "raw" ] && axiom_scn_reg 30 0x4000

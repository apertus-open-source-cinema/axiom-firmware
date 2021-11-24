#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

DISP=${1:-1080p60}

# devmem 0x80010018 w 0x00000

axiom_gen_init.sh $DISP
axiom_data_init.sh
axiom_rmem_conf.sh
# ./wmem_conf.sh
# ./linear_conf.sh 1.3 0.0
# ./remap_conf.sh $DISP
# ./gamma_conf.sh 1

# ./mat4_conf.sh  1 0 0 0  0 1 0 0  0 0 1 0  0 0 0 1  0 0 0 0
# ./mat4_conf.sh 1 0 0 0  0 0.5 0.5 0  0 0.5 0.5 0  0 0 0 1  0 0 0 0


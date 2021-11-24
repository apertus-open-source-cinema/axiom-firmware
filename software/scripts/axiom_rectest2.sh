#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

#./mat4_conf.sh 0 0.5 0.5 0  0 0 0 1  0 0.5 0.5 0  1 0 0 0
#for n in `seq 0 8`; do sleep 0.8; axiom_scn_reg 31 0x${n}01; done
#./mat4_conf.sh 0 0 1 0  0 0 0 1  0 1 0 0  1 0 0 0
#for n in `seq 0 8`; do sleep 0.8; axiom_scn_reg 31 0x${n}01; done
#./mat4_conf.sh 0 1 0 0  0 0 0 1  0 0 1 0  1 0 0 0
#for n in `seq 0 8`; do sleep 0.8; axiom_scn_reg 31 0x${n}01; done

for t in 1 2 3 4; do

    axiom_mimg -a -T $t

    axiom_mat4_conf.sh 0 0.5 0.5 0  0 0 0 1  0 0.5 0.5 0  1 0 0 0
    for n in `seq 0 8`; do sleep 0.2; axiom_scn_reg 31 0x${n}01; done
    axiom_mat4_conf.sh 0 0 1 0  0 0 0 1  0 1 0 0  1 0 0 0
    for n in `seq 0 8`; do sleep 0.2; axiom_scn_reg 31 0x${n}01; done
    mxiom_at4_conf.sh 0 1 0 0  0 0 0 1  0 0 1 0  1 0 0 0
    for n in `seq 0 8`; do sleep 0.2; axiom_scn_reg 31 0x${n}01; done
	
done

for f in /opt/overlays/*.raw.xz; do

    xzcat $f | axiom_mimg -r -w

    axiom_mat4_conf.sh 0 0.5 0.5 0  0 0 0 1  0 0.5 0.5 0  1 0 0 0
    for n in `seq 0 8`; do sleep 0.2; axiom_scn_reg 31 0x${n}01; done
    axiom_mat4_conf.sh 0 0 1 0  0 0 0 1  0 1 0 0  1 0 0 0
    for n in `seq 0 8`; do sleep 0.2; axiom_scn_reg 31 0x${n}01; done
    axiom_mat4_conf.sh 0 1 0 0  0 0 0 1  0 0 1 0  1 0 0 0
    for n in `seq 0 8`; do sleep 0.2; axiom_scn_reg 31 0x${n}01; done
	
done


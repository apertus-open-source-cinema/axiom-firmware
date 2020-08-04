#!/bin/bash
# devmem 0x80010018 32 0x00000

# ./gen_init.sh 1080p60
# ./gen_init.sh 1080p50
# ./gen_init.sh 1080p30
# ./gen_init.sh 1080p24
axiom_gen_init.sh SHOGUN

axiom_data_init.sh
axiom_rmem_conf.sh
axiom_wmem_conf.sh
# ./linear_conf.sh 1.3 0.0
axiom_linear_conf.sh 1.0 0.0
# ./linear_conf.sh 1.6 0.0
# ./remap_conf.sh $DISP
# ./gamma_conf.sh 1
axiom_gamma_conf.sh 0.8

# ./mat4_conf.sh  1 0 0 0  0 1 0 0  0 0 1 0  0 0 0 1  0 0 0 0
# ./mat4_conf.sh 1 0 0 0  0 0.5 0.5 0  0 0.5 0.5 0  0 0 0 1  0 0 0 0
# ./mat4_conf.sh 0.3 0.3 0.3 0.3  0 0 0 1  0 0.5 0.5 0  1 0 0 0
axiom_mat4_conf.sh 0.3 0.3 0.3 0.3  0 0 0 1  0 0.42 0.42 0  1 0 0 0

axiom_scn_reg 31 3
axiom_scn_reg 31 1


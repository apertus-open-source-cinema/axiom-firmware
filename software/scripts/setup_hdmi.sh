#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir

DISP=${1:-1080p60}

. ./hdmi.func

# devmem 0x80010018 w 0x00000

bash -x ./gen_init.sh $DISP
./data_init.sh
./rmem_conf.sh
# ./wmem_conf.sh
# ./linear_conf.sh 1.3 0.0
# ./remap_conf.sh $DISP
# ./gamma_conf.sh 1

# ./mat4_conf.sh  1 0 0 0  0 1 0 0  0 0 1 0  0 0 0 1  0 0 0 0
# ./mat4_conf.sh 1 0 0 0  0 0.5 0.5 0  0 0.5 0.5 0  0 0 0 1  0 0 0 0


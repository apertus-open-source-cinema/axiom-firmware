#!/bin/bash

./mat4_conf.sh 0 0.5 0.5 0  0 0 0 1  0 0.5 0.5 0  1 0 0 0
for n in `seq 0 8`; do sleep 0.3; scn_reg 31 0x${n}01; done
./mat4_conf.sh 0 0 1 0  0 0 0 1  0 1 0 0  1 0 0 0
for n in `seq 0 8`; do sleep 0.3; scn_reg 31 0x${n}01; done
./mat4_conf.sh 0 1 0 0  0 0 0 1  0 0 1 0  1 0 0 0
for n in `seq 0 8`; do sleep 0.3; scn_reg 31 0x${n}01; done

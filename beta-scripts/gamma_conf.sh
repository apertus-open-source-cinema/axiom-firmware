#!/bin/bash

cd "${0%/*}"            # change into script dir

MAX=65536
GAMMA=${1:-1.0}

./lut_conf3 -N 4096 -M $MAX -G $GAMMA -B 0x80300000
./lut_conf3 -N 4096 -M $MAX -G $GAMMA -B 0x80304000
./lut_conf3 -N 4096 -M $MAX -G $GAMMA -B 0x80308000
./lut_conf3 -N 4096 -M $MAX -G $GAMMA -B 0x8030C000

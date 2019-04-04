#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir

MAX=65536
GAMMA=${1:-1.0}

../processing_tools/lut_conf/lut_conf -N 4096 -M $MAX -G $GAMMA -B 0x80300000
../processing_tools/lut_conf/lut_conf -N 4096 -M $MAX -G $GAMMA -B 0x80304000
../processing_tools/lut_conf/lut_conf -N 4096 -M $MAX -G $GAMMA -B 0x80308000
../processing_tools/lut_conf/lut_conf -N 4096 -M $MAX -G $GAMMA -B 0x8030C000

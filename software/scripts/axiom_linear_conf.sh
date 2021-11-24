#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

MIN=-131072
MAX=131071
FACTOR=`dc -e "5k ${1:-1.0} 0.5 * p"`
OFFSET=`dc -e "5k ${2:-0.0} 65536 * p"`

axiom_lut_conf -N 4096 -m $MIN -M $MAX -F $FACTOR -O $OFFSET -B 0x60500000
axiom_lut_conf -N 4096 -m $MIN -M $MAX -F $FACTOR -O $OFFSET -B 0x60504000
axiom_lut_conf -N 4096 -m $MIN -M $MAX -F $FACTOR -O $OFFSET -B 0x60508000
axiom_lut_conf -N 4096 -m $MIN -M $MAX -F $FACTOR -O $OFFSET -B 0x6050C000

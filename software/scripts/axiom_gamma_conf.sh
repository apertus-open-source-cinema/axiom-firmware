#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

MAX=65536
GAMMA=${1:-1.0}

axiom_lut_conf -N 4096 -M $MAX -G $GAMMA -B 0x80300000
axiom_lut_conf -N 4096 -M $MAX -G $GAMMA -B 0x80304000
axiom_lut_conf -N 4096 -M $MAX -G $GAMMA -B 0x80308000
axiom_lut_conf -N 4096 -M $MAX -G $GAMMA -B 0x8030C000

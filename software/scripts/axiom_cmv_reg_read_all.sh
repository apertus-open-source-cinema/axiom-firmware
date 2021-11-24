#!/bin/bash

# SPDX-FileCopyrightText: © 2016 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

for n in `seq 0 4 511`; do axiom_mem_reg $(( 0x60000000 + n )); done

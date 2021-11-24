#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

REGS=( 0x0{6,7,8,9,A,B,C,D,E,F} )
REGS=( ${REGS[*]} 0x1{0,1,2,3,4,5,6,7,8,9,A} )
REGS=( ${REGS[*]} 0x27 0x28 0x4E 0x4F )


for n in ${REGS[*]}; do
    VAL=`axiom_pll_reg $n`
    printf "0x%02X\t0x%04X\n" $[n+0] $VAL
done


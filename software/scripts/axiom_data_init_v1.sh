#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

[ $# -gt 2 ] && {
    DX=${1:-0}
    DY=${2:-41}
    DW=${3:-1920}
    DH=${4:-1080}
} || {
    DX=$(( `axiom_scn_reg 4` - 15 ))
    DY=$(( `axiom_scn_reg 6` ))
    DW=${1:-0}
    DH=${2:-0}
}

[ $DW -eq 0 ] && DW=$(( `axiom_scn_reg 5` - DX ))
[ $DH -eq 0 ] && DH=$(( `axiom_scn_reg 7` - DY ))

DW=$(( (DW+15)/16*16 ))		# align

axiom_scn_reg 12 $DX			# hdata_s
axiom_scn_reg 13 $(( DX + DW ))	# hdata_e
axiom_scn_reg 14 $DY			# vdata_s
axiom_scn_reg 15 $(( DY + DH ))	# vdata_e

[ $DY -ge 10 ] && {
    RY=$(( DY - 10 ))
} || {
    RY=$(( DY + DH + 1 ))
}

axiom_scn_reg 16  $(( DX + 1*DW/4 ))	# event0
axiom_scn_reg 17  $(( DX + 2*DW/4 ))	# event1
axiom_scn_reg 18  $(( DX + 3*DW/4 ))	# event2
axiom_scn_reg 19  $(( DX + 4*DW/4 ))	# event3

axiom_scn_reg 20  $(( RY ))		# event4
axiom_scn_reg 21  $(( RY + 1 ))	# event5
axiom_scn_reg 22  $(( RY + 2 ))	# event6
axiom_scn_reg 23  $(( RY + 5 ))	# event7


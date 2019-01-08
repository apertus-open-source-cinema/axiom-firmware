#!/bin/sh

. ./hdmi.func

[ $# -gt 2 ] && {
    DX=${1:-0}
    DY=${2:-41}
    DW=${3:-1920}
    DH=${4:-1080}
} || {
    DX=$(( `scn_reg 4` - 15 ))
    DY=$(( `scn_reg 6` ))
    DW=${1:-0}
    DH=${2:-0}
}

[ $DW -eq 0 ] && DW=$(( `scn_reg 5` - DX ))
[ $DH -eq 0 ] && DH=$(( `scn_reg 7` - DY ))

DW=$(( (DW+15)/16*16 ))		# align

scn_reg 12 $DX			# hdata_s
scn_reg 13 $(( DX + DW ))	# hdata_e
scn_reg 14 $DY			# vdata_s
scn_reg 15 $(( DY + DH ))	# vdata_e

[ $DY -ge 10 ] && {
    RY=$(( DY - 10 ))
} || {
    RY=$(( DY + DH + 1 ))
}

scn_reg 16  $(( DX + 1*DW/4 ))	# event0
scn_reg 17  $(( DX + 2*DW/4 ))	# event1
scn_reg 18  $(( DX + 3*DW/4 ))	# event2
scn_reg 19  $(( DX + 4*DW/4 ))	# event3

scn_reg 20  $(( RY ))		# event4
scn_reg 21  $(( RY + 1 ))	# event5
scn_reg 22  $(( RY + 2 ))	# event6
scn_reg 23  $(( RY + 5 ))	# event7


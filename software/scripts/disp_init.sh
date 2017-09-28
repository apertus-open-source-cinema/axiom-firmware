#!/bin/sh

. ./hdmi.func

[ $# -gt 2 ] && {
    DX=${1:-14}
    DY=${2:-41}
    DW=${3:-1920}
    DH=${4:-1080}
} || {
    DX=14
    DY=41
    DW=${1:-1920}
    DH=${2:-1080}
}

# home
# DX=${1:-0}
# DY=${2:-0}

EO=0x8000
EO=0x0000

scn_reg  4 $DX
scn_reg  5 $(( (DX + DW) | EO ))
scn_reg  6 $DY
scn_reg  7 $(( DY + DH ))


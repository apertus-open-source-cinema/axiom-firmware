#!/bin/bash
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

axiom_scn_reg  4 $DX
axiom_scn_reg  5 $(( (DX + DW) | EO ))
axiom_scn_reg  6 $DY
axiom_scn_reg  7 $(( DY + DH ))


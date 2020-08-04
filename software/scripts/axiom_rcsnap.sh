#!/bin/bash
cadr=$[ 0x60300000 + ${1:-0}*4 ]
radr=$[ 0x60304000 + ${2:-0}*4 ]

cval=${3:-0x111}
rval=${4:-0x222}

axiom_snap -t -p -e 100n -d >/tmp/test00.raw16
axiom_mem_reg $cadr $cval -2
axiom_snap -t -p -e 100n -d >/tmp/test01.raw16
axiom_mem_reg $radr $rval -2
axiom_snap -t -p -e 100n -d >/tmp/test11.raw16
axiom_mem_reg $cadr 0x0 -2
axiom_snap -t -p -e 100n -d >/tmp/test10.raw16
axiom_mem_reg $radr 0x0 -2

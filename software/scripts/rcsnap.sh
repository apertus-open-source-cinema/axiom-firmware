#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir


cadr=$[ 0x60300000 + ${1:-0}*4 ]
radr=$[ 0x60304000 + ${2:-0}*4 ]

cval=${3:-0x111}
rval=${4:-0x222}

../cmv_tools/cmv_snap3/cmv_snap3 -t -p -e 100n -d >/tmp/test00.raw16
devmem $cadr 16 $cval
../cmv_tools/cmv_snap3/cmv_snap3 -t -p -e 100n -d >/tmp/test01.raw16
devmem $radr 16 $rval
../cmv_tools/cmv_snap3/cmv_snap3 -t -p -e 100n -d >/tmp/test11.raw16
devmem $cadr 16 0x0
../cmv_tools/cmv_snap3/cmv_snap3 -t -p -e 100n -d >/tmp/test10.raw16
devmem $radr 16 0x0

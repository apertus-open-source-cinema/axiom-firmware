#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir


export BETA=192.168.1.101 # replace by your camera IP

ssh root@$BETA "axiom_rcn-clear"
ssh root@$BETA "axiom_snap -2 -b -r -e 10ms" > dark-check-1.raw12

ssh root@$BETA "axiom_rcn_darkframe darkframe-x1.pgm"
ssh root@$BETA "axiom_snap -2 -b -r -e 10ms" > dark-check-2.raw12

./raw2dng --no-darkframe --check-darkframe dark-check-1.raw12
./raw2dng --no-darkframe --check-darkframe dark-check-2.raw12

rm dark-check-1.raw12 
rm dark-check-2.raw12

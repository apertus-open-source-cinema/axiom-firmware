#!/bin/bash
. ./cmv.func

for n in `seq 0 4 511`; do devmem $(( 0x60000000 + n )) w; done

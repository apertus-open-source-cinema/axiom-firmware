#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir

for n in `seq 0 4 511`; do /sbin/devmem $(( 0x60000000 + n )) 32; done

#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir

for n in `seq 0 4 511`; do devmem2 $(( 0x60000000 + n )) w; done

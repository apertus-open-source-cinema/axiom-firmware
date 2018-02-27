#!/bin/bash

for n in `seq 0 4 511`; do devmem2 $(( 0x60000000 + n )) w; done

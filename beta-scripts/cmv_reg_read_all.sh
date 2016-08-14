#!/bin/bash

for n in `seq 0 4 511`; do /sbin/devmem $(( 0x60000000 + n )) 32; done

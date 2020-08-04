#!/bin/bash
for n in `seq 0 4 511`; do axiom_mem_reg $(( 0x60000000 + n )); done

#!/bin/bash

buf=(`axiom_gen_reg 0` `axiom_gen_reg 2` `axiom_gen_reg 4` `axiom_gen_reg 6`)
act=(`axiom_scn_reg 4` `axiom_scn_reg 5` `axiom_scn_reg 6` `axiom_scn_reg 7`)
AW=$[ ${act[1]} - ${act[0]} ]
AH=$[ ${act[3]} - ${act[2]} ]

off=(0 $[ ($AW-1)*8 ] $[ ($AH-1)*2048*8 ] $[ (($AH-1)*2048+$AW-1)*8 ])

for b in ${buf[*]}; do
    for o in ${off[*]}; do
    	a=$[ $b + $o ]
	memtool -8 -n -F 0xF000 $a 1
    done
done

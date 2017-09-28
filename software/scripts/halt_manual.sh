#!/bin/sh

cd "${0%/*}"            # change into script dir

. ./cmv.func
. ./hdmi.func

fil_reg 11 0xFC01F010	# block writer

./mimg -a -P 0
./mimg -a -o -P 0

gen_reg 11 0x0004F010	# block reader
fil_reg 15 0x10
gen_reg 11 0x10


#!/bin/bash
axiom_fil_reg 11 0xFC01F010	# block writer

axiom_mimg -a -P 0
axiom_mimg -a -o -P 0

axiom_gen_reg 11 0x0004F010	# block reader
axiom_fil_reg 15 0x10
axiom_gen_reg 11 0x10


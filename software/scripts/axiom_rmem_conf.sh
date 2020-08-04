#!/bin/bash
xo=${1:-64}
yo=${2:-228}
off=$[ ((xo & ~1) + yo*2048)*8 ]

# axiom_gen_reg 0 0x18100380
axiom_gen_reg 0 $[ 0x18000000 + off ]
axiom_gen_reg 1 0x19FF0000

# axiom_gen_reg 2 0x1A100380
axiom_gen_reg 2 $[ 0x1A000000 + off ]
axiom_gen_reg 3 0x1BFF0000

# axiom_gen_reg 4 0x1C100380
axiom_gen_reg 4 $[ 0x1C000000 + off ]
axiom_gen_reg 5 0x1DFF0000

# axiom_gen_reg 6 0x1E100380
axiom_gen_reg 6 $[ 0x1E000000 + off ]
axiom_gen_reg 7 0x1FFF0000


#	4096 pixels, 2 rows -> 8192 pixels, 4 pixel/64bit 
LW=$(( (64/8) * 4096 * 2 / 4 ))
LW=${3:-$LW}

[ $LW -eq 0 ] && exit 0

axiom_gen_reg 8 0x80

DW=$(( (`axiom_scn_reg 13` & 0xFFF) - `axiom_scn_reg 12` ))
CC=$(( DW ))

axiom_gen_reg 9 $(( LW - CC * (64/8) + 0x80 ))
axiom_gen_reg 10 $(( CC/16 - 2 ))

DH=$(( `axiom_scn_reg 15` - `axiom_scn_reg 14` ))
RC=$(( DH ))

# devmem 0x80000030 w 0xFEFE5031		# single
# devmem 0x80000030 w 0x4050FE31		# flip

axiom_scn_reg 24 0xFE31		# switch
axiom_scn_reg 25 0x5050		# switch
axiom_scn_reg 26 0xFEE1
axiom_scn_reg 27 0xFEFE

axiom_gen_reg 11 0x4F000

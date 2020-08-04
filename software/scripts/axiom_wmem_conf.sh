#!/bin/bash
axiom_fil_reg 0 0x18000000
axiom_fil_reg 1 0x19FF0000

axiom_fil_reg 2 0x1A000000
axiom_fil_reg 3 0x1BFF0000

axiom_fil_reg 4 0x1C000000
axiom_fil_reg 5 0x1DFF0000

axiom_fil_reg 6 0x1E000000
axiom_fil_reg 7 0x1FFF0000

axiom_fil_reg 8 0x80
axiom_fil_reg 9 0x80
axiom_fil_reg 10 0x7E

axiom_fil_reg 12 0xA95
axiom_fil_reg 13 0x070707

# axiom_fil_reg 11 0xFC01F000
axiom_fil_reg 11 0xFC31F000	# clipping

# ./pmem -m Z0x18000000+0x8000000

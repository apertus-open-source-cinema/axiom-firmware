#!/bin/sh

cd "${0%/*}"            # change into script dir

. ./cmv.func

fil_reg 0 0x18000000
fil_reg 1 0x19FF0000

fil_reg 2 0x1A000000
fil_reg 3 0x1BFF0000

fil_reg 4 0x1C000000
fil_reg 5 0x1DFF0000

fil_reg 6 0x1E000000
fil_reg 7 0x1FFF0000

fil_reg 8 0x80
fil_reg 9 0x80
fil_reg 10 0x7E

fil_reg 12 0xA95
fil_reg 13 0x070707

# fil_reg 11 0xFC01F000
fil_reg 11 0xFC31F000	# clipping

# ./pmem -m Z0x18000000+0x8000000

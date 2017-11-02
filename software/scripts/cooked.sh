#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir

fil_reg 15 0x0
fil_reg 11 0xFC01F000
fil_reg 13 0x00070707
../cmv_tools/cmv_snap3/cmv_snap3  -t -p -e 100n -d >/tmp/cooked.data

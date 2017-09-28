#!/bin/bash

fil_reg 15 0x0
fil_reg 11 0xFF01F000
fil_reg 13 0x00070000
./cmv_snap3 -t -p -e 100n -d -S0 >/tmp/raw.data

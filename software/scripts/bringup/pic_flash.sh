#!/bin/bash

i2cset -y 2 0x70 0x0 0x5	# RFW
i2cset -y 0 0x23 0x14 0x1F	# take pic out of reset
i2cdetect -r -y -a 2

./pic_jtag_extest.sh

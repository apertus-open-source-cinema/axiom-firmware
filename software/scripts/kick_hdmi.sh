#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir

. ./cmv.func

./fclk_init.sh
./zynq_info.sh
./power_init.sh

sleep 1

cat cmv_hdmi4.bit >/dev/xdevcfg

./power_on.sh
./pac1720_info.sh

# fil_reg 15 0x08000800
# fil_reg 15 0x0

# ./cmv_init.sh
# ../cmv_tools/cmv_train3/cmv_train3

# ./setup.sh
# bash -x ./setup_hdmi.sh

# fil_reg 15 0x01000100

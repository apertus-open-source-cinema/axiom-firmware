#!/bin/bash

# this script initializes and starts the image streaming pipeline
# it was previously known as kick.sh / kick-manual.sh

cd $(dirname $(realpath $0))    # change into script dir
. ./cmv.func


. ./cmv.func
. ./hdmi.func

./fclk_init.sh
./zynq_info.sh

echo axiom-fpga-main.bin > /sys/class/fpga_manager/fpga0/firmware

devmem 0xF8006210 w 0x00001
devmem 0xF8006214 w 0x00001
devmem 0xF8000600 w 0x84

./power_init.sh
./power_on.sh
./pac1720_info.sh

while sleep 1; do
    ./power_on.sh

    fil_reg 15 0x08000800
    fil_reg 15 0x0

    ./cmv_init.sh
    ../sensor_tools/train/train && break

    ./power_init.sh
done

./setup.sh
./ingmar.sh
# ./hdmi_init.sh
# ./pic_jtag_pcie.py 0x00 0x12

fil_reg 15 0x01000100

../processing_tools/mimg/mimg -a -O /opt/overlays/AXIOM-Beta-logo-overlay-white.raw

# scn_reg 32  264		# pream_s
# scn_reg 33  264		# guard_s

# scn_reg  9  2100
# scn_reg  8  0

#./hdmi_init2.sh
./rf_sel.py A
./pic_jtag_pcie.py 0x92 0x92

# ./rest_pll.sh <PLL/5000kHz.pll

./set_gain.sh 1
#./rcn_darkframe.py darkframe-x1.pgm


#!/bin/bash

cd "${0%/*}"            # change into script dir

. ./cmv.func
. ./hdmi.func

./fclk_init.sh
./zynq_info.sh

cat cmv_hdmi3.bit >/dev/xdevcfg

devmem 0xF8006210 32 0x00001
devmem 0xF8006214 32 0x00001
devmem 0xF8000600 32 0x84

./power_init.sh
./power_on.sh
./pac1720_info.sh

while sleep 1; do
    ./power_on.sh

    fil_reg 15 0x08000800
    fil_reg 15 0x0

    ./cmv_init.sh
    ./cmv_train3 && break

    ./power_init.sh
done

./setup.sh
./ingmar.sh
# ./hdmi_init.sh
# ./pic_jtag_pcie.py 0x00 0x12

fil_reg 15 0x01000100

# ./mimg -a -o /opt/IMG/overlay_05.rgb
/opt/BERTL/mimg -a -O /opt/IMG/AXIOM-Beta-logo-overlay-white.raw

# scn_reg 32  264		# pream_s
# scn_reg 33  264		# guard_s

# scn_reg  9  2100
# scn_reg  8  0

./hdmi_init2.sh
./rf_sel.py A
./pic_jtag_pcie.py 0x92 0x92

# ./rest_pll.sh <PLL/5000kHz.pll

./set_gain.sh 1
./rcn_darkframe.py darkframe-x1.pgm


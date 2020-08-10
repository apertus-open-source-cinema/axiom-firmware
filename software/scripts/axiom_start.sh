#!/bin/bash

# this script initializes and starts the image streaming pipeline
# it was previously known as kick.sh / kick-manual.sh

axiom_fclk_init.sh
axiom_zynq_info.sh

echo axiom_fpga_main.bin > /sys/class/fpga_manager/fpga0/firmware

axiom_mem_reg -4 0xF8006210 0x00001
axiom_mem_reg -4 0xF8006214 0x00001
axiom_mem_reg -4 0xF8000600 0x84

axiom_power_init.sh
axiom_power_on.sh
axiom_pac1720_info.sh

while sleep 1; do
    axiom_power_on.sh

    axiom_fil_reg 15 0x08000800
    axiom_fil_reg 15 0x0

    axiom_cmv_init.sh
    axiom_train && break

    axiom_power_init.sh
done

axiom_setup.sh
# ./ingmar.sh # obsolete
# ./hdmi_init.sh
# ./pic_jtag_pcie.py 0x00 0x12

axiom_fil_reg 15 0x01000100

axiom_mimg -a -O /opt/overlays/AXIOM-Beta-logo-overlay-white.raw

# axiom_scn_reg 32  264		# pream_s
# axiom_scn_reg 33  264		# guard_s

# axiom_scn_reg  9  2100
# axiom_scn_reg  8  0

#./hdmi_init2.sh
axiom_rf_sel.py A
axiom_pic_jtag_pcie.py 0x92 0x92

# ./rest_pll.sh <PLL/5000kHz.pll

axiom_set_gain.sh 1
#./rcn_darkframe.py darkframe-x1.pgm


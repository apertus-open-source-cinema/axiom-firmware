#!/bin/bash

# SPDX-FileCopyrightText: © 2017-2024 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

# this script initializes and starts the image streaming pipeline
# it was previously known as kick.sh / kick-manual.sh

if [ "$EUID" -ne 0 ]
  then echo "please run as root, 'sudo axiom_start.sh'"
  exit
fi

# running axiom_start.sh twice will crash the camera, this should prevent that from happening
FILE=/tmp/axiom.started
if [[ -f "$FILE" ]]; then
    echo "AXIOM service seems to be running already, if that is not the case please remove the /tmp/axiom.started file and try again."
    exit
fi


MODE=${1:-normal}

axiom_fclk_init.sh
axiom_zynq_info.sh

# clear the in memory framebuffers
memtool -1 -F 0x0 0x18000000 0x8000000

# FPGA bitstreams in bin format are loaded from /lib/firmware/
echo axiom_fpga_main.bin > /sys/class/fpga_manager/fpga0/firmware

axiom_mem_reg -4 0xF8006210 0x00001
axiom_mem_reg -4 0xF8006214 0x00001
axiom_mem_reg -4 0xF8000600 0x84

memtool -w -4 0x80400000 0x200 </opt/axiom-firmware/peripherals/pll/HDMI_148500KHZ.pll

axiom_power_init.sh
axiom_gpio.py init
axiom_power_on.sh
axiom_pac1720_info.sh

while sleep 1; do
    axiom_power_on.sh

    axiom_fil_reg 15 0x08000800
    axiom_fil_reg 15 0x0

    [ "$MODE" == "raw" ] && axiom_fil_reg 11 0x00000031

    axiom_cmv_init.sh
    axiom_train && break

    axiom_power_init.sh
    axiom_gpio.py init
done

[ "$MODE" == "raw" ] && i2c0_bit_set 0x22 0x15 7

axiom_setup.sh $MODE
# ./hdmi_init.sh
# ./pic_jtag_pcie.py 0x00 0x12

axiom_fil_reg 15 0x01000100

# show overlay in normal mode - clear overlay in raw mode
[ "$MODE" == "normal" ] && axiom_mimg -a -O /opt/overlays/AXIOM-Beta-logo-overlay-white.raw
[ "$MODE" == "raw" ] && axiom_mimg -O -P0


# initiate HDMI
axiom_hdmi_init3.sh

# load HDMI data islands
# generate AVI info frame, create a packet and upload it to the packet buffer
axiom_infoframe.py | axiom_makepkt.py | axiom_packet.py

# generate vendor frame (AXIOM Beta) and upload it into the second slot of the packet buffer
axiom_vendorframe.py | axiom_makepkt.py | axiom_packet.py /dev/stdin 32


axiom_rf_sel.py A
axiom_pic_jtag_pcie.py 0x92 0x92


# set analog gain to 1 (unity gain - no amplification)
axiom_set_gain.sh 1


# raw mode related commands
if [ "$MODE" == "raw" ]; then 
	axiom_scn_reg 28 0x7700
	axiom_scn_reg 28 0x7000
	axiom_scn_reg 31 0x0000  # top HDMI plugin module set normal color mode
	axiom_scn_reg 30 0x7000  # bottom HDMI plugin module set to alternating A/B raw frames  
	axiom_raw_mark.sh        # enable corner markers
	axiom_scn_reg 2 0x100    # set corner marker frame counter max to 256
fi


#./rcn_darkframe.py darkframe-x1.pgm

# running axiom_start.sh twice will crash the camera, this should prevent that from happening
touch /tmp/axiom.started



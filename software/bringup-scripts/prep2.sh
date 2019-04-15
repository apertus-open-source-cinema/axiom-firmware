#!/bin/bash

../scripts/power_init.sh
../scripts/power_on.sh
../scripts/fclk_init.sh

echo icsp.bin > /sys/class/fpga_manager/fpga0/firmware

sleep 1

../scripts/rf_sel.py B
./pic_jtag_cso.py 0xF
../scripts/rf_sel.py A
../scripts/pic_jtag_pcie.py 0x01 0x92


#!/bin/bash

axiom_power_init.sh
axiom_power_on.sh
axiom_fclk_init.sh

echo icsp.bin > /sys/class/fpga_manager/fpga0/firmware

sleep 1

axiom_rf_sel.py B
axiom_pic_jtag_cso.py 0xF
axiom_rf_sel.py A
axiom_pic_jtag_pcie.py 0x01 0x92

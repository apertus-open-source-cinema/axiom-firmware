#!/bin/bash

./power_init.sh
./power_on.sh
./fclk_init.sh

cat icsp.bit >/dev/xdevcfg

sleep 1

./rf_sel.py B
./pic_jtag_cso.py 0xF
./rf_sel.py A
./pic_jtag_pcie.py 0x01 0x92


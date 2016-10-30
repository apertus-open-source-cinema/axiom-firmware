#!/bin/bash

./power_init.sh
./power_on.sh
./fclk_init.sh

cat icsp.bit >/dev/xdevcfg

echo "Z<" >/dev/ttyPS1

./rf_sel.py B
./pic_jtag_load.py pass_spkfan.cfg pass_spkfan.ufm

cat check_spkfan.bit >/dev/xdevcfg 
./spkfan_init.sh 

echo 1 >/sys/class/gpio/gpio962/value


#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir


./../scripts/power_init.sh
./../scripts/power_on.sh
./../scripts/fclk_init.sh

echo icsp.bin > /sys/class/fpga_manager/fpga0/firmware

echo "Z<" >/dev/ttyPS1

./../scripts/rf_sel.py B
./pic_jtag_load.py pass_spkfan.cfg pass_spkfan.ufm

echo check_spkfan.bit > /sys/class/fpga_manager/fpga0/firmware
./../scripts/spkfan_init.sh 

echo 1 >/sys/class/gpio/gpio962/value


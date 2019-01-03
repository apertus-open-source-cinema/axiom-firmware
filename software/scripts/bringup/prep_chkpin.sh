#!/bin/bash

./power_init.sh
./power_on.sh
./fclk_init.sh
./gpio.py init

cat check_pin.bit >/dev/xdevcfg
sleep 0.2

./rf_disable.sh


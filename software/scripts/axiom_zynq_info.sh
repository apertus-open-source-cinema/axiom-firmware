#!/bin/bash

# SPDX-FileCopyrightText: © 2017 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

ZTO=`cat /sys/devices/soc0/amba/*.adc/iio*/in_temp0_offset`
ZTR=`cat /sys/devices/soc0/amba/*.adc/iio*/in_temp0_raw` 
ZTS=`cat /sys/devices/soc0/amba/*.adc/iio*/in_temp0_scale` 

ZT=`dc -e "5k $ZTR ${ZTO/-/_} + $ZTS * 1000 / p"`

printf "%-14.14s\t%8.4f °C\n" "Temp" $ZT

for n in /sys/devices/soc0/amba/*.adc/iio*/in_voltage*raw; do
    b=${n%_raw}

    ZVN=V${b##*_v}
    ZVR=`cat $n`
    ZVS=`cat ${b}_scale`

    ZV=`dc -e "5k ${ZVR/-/_} $ZVS * 1000 / p"`

    printf "%-14.14s\t%8.4f V\n" $ZVN $ZV
done


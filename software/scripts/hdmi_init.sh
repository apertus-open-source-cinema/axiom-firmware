#!/bin/bash

EMIOBASE=960

for n in `seq 0 63`; do 
    N=$[ EMIOBASE + n ]
    gpio=/sys/class/gpio/gpio$N
    [ -e $gpio ] ||
	echo $N >/sys/class/gpio/export
    echo out >$gpio/direction
    echo 0 >$gpio/value
done

echo 1 >/sys/class/gpio/gpio975/value 	# serdes reset
echo 1 >/sys/class/gpio/gpio974/value 	# hdmi reset
echo 1 >/sys/class/gpio/gpio973/value 	# blue led
echo 1 >/sys/class/gpio/gpio972/value 	# blue led source

echo 0 >/sys/class/gpio/gpio974/value 	# hdmi reset
echo 0 >/sys/class/gpio/gpio975/value 	# serdes reset

echo 1 >/sys/class/gpio/gpio978/value	# clock select

# i2cset -y 0 0x23 0x14 0xFF	# reset pic
# i2cset -y 2 0x70 0x0 0x5	# RFW
# i2cset -y 0 0x23 0x14 0x1F	# take pic out of reset
# sleep 0.5
# i2cdetect -r -y -a 2

./rf_disable.sh


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

echo 1 >/sys/class/gpio/gpio974/value 
echo 1 >/sys/class/gpio/gpio973/value 
echo 1 >/sys/class/gpio/gpio972/value 

echo 0 >/sys/class/gpio/gpio974/value 


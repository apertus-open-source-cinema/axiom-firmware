#!/bin/bash

# SPDX-FileCopyrightText: © 2016 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

EMIOBASE=960

for n in `seq 0 63`; do 
    N=$[ EMIOBASE + n ]
    gpio=/sys/class/gpio/gpio$N
    [ -e $gpio ] ||
	echo $N >/sys/class/gpio/export
    echo out >$gpio/direction
    echo 0 >$gpio/value
done


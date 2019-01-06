#!/bin/sh

cd "${0%/*}"		# change into script dir

. ./i2c.func

i2c_set 0x22 0x14 0x0F


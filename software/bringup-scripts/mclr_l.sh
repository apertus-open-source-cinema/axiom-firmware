#!/bin/bash

cd "${0%/*}"		# change into script dir

. ../scripts/i2c.func

i2c_set 0x22 0x14 0x0F


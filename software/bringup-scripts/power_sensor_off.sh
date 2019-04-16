#!/bin/sh

cd "${0%/*}"		# change into script dir

. ../scripts/i2c.func

for id in 0x21; do
    i2c_test $id || continue

    i2c_set $id 0x14 0x00
    i2c_set $id 0x15 0x00
done


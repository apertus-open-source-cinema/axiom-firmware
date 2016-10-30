#!/bin/sh

cd "${0%/*}"		# change into script dir

. ./i2c.func

for id in 0x20 0x21; do
    i2c_test $id || continue

    i2c_set $id 0x14 0xFF
    i2c_set $id 0x15 0xFF
done

for id in 0x22 0x23; do
    i2c_test $id || continue

    i2c_set $id 0x14 0x4F
    i2c_set $id 0x15 0x3C
done


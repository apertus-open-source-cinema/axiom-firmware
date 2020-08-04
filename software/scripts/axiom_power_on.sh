#!/bin/bash
for id in 0x20 0x21; do
    axiom_i2c_test $id || continue

    axiom_i2c_set $id 0x14 0xFF
    axiom_i2c_set $id 0x15 0xFF
done

for id in 0x22 0x23; do
    axiom_i2c_test $id || continue

    axiom_i2c_set $id 0x14 0x4F
    axiom_i2c_set $id 0x15 0x3C
done


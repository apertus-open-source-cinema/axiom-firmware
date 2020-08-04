#!/bin/bash
# disable power to RFs

axiom_i2c0_bit_set 0x22 0x14 1
axiom_i2c0_bit_set 0x22 0x14 3
axiom_i2c0_bit_set 0x23 0x14 1
axiom_i2c0_bit_set 0x23 0x14 3

# take PICs out of reset

axiom_i2c0_bit_set 0x22 0x14 4
axiom_i2c0_bit_set 0x23 0x14 4

#!/bin/bash

. ./i2c0.func 

# enable VIO

i2c0_bit_set 0x20 0x14 5


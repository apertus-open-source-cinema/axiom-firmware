#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

for id in 0x20 0x21; do
    i2c_test $id || continue

    i2c_set $id 0x00 0x55
    i2c_set $id 0x01 0x55

    i2c_set $id 0x0c 0xAA
    i2c_set $id 0x0d 0xAA

    i2c_set $id 0x14 0x00
    i2c_set $id 0x15 0x00
done

for id in 0x22 0x23; do
    i2c_test $id || continue

    i2c_set $id 0x00 0xA5
    i2c_set $id 0x01 0xC3

    i2c_set $id 0x0c 0x5A
    i2c_set $id 0x0d 0x3C

    i2c_set $id 0x14 0x00
    i2c_set $id 0x15 0x00
done

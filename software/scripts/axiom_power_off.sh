#!/bin/bash

# SPDX-FileCopyrightText: © 2016 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

for id in 0x20 0x21 0x22 0x23; do
    i2c_test $id || continue

    i2c_set $id 0x14 0x00
    i2c_set $id 0x15 0x00
done


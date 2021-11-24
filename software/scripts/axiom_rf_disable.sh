#!/bin/bash

# SPDX-FileCopyrightText: © 2016 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

# disable power to RFs

i2c0_bit_clr 0x22 0x14 1
i2c0_bit_clr 0x22 0x14 3
i2c0_bit_clr 0x23 0x14 1
i2c0_bit_clr 0x23 0x14 3

# take PICs out of reset

i2c0_bit_set 0x22 0x14 4
i2c0_bit_set 0x23 0x14 4

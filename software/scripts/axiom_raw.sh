#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

axiom_fil_reg 15 0x0
axiom_fil_reg 11 0xFF01F000
axiom_fil_reg 13 0x00070000
axiom_snap -t -p -e 100n -d -S0 >/tmp/raw.data

#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

while read R V; do
    [ -n "$R" -a -n "$V" ] && axiom_pll_reg $R $V
done


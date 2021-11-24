#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

OFF=${1:-0}

while read B R V; do
    [ "$B" == "#" ] && continue
    [ -n "$R" -a -n "$V" ] && mem_reg $[R+OFF]  $V
done


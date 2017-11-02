#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir


. ./hdmi.func


while read R V; do
    [ -n "$R" -a -n "$V" ] && pll_reg $R $V
done


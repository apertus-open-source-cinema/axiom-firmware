#!/bin/bash

. ./hdmi.func


while read R V; do
    [ -n "$R" -a -n "$V" ] && pll_reg $R $V
done


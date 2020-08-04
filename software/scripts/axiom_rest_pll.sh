#!/bin/bash
while read R V; do
    [ -n "$R" -a -n "$V" ] && axiom_pll_reg $R $V
done


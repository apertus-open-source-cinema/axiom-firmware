#!/bin/sh
cd $(dirname $(realpath $0))    # change into script dir

. ./hdmi.func


OFF=${1:-0}

while read B R V; do
    [ "$B" == "#" ] && continue
    [ -n "$R" -a -n "$V" ] && mem_reg $[R+OFF]  $V
done


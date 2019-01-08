#!/bin/bash

echo -en "\e[34m"
gpvo -s "$1" \
    | sed -n '/Header/ {n;N;N;N; s/\(^\|\n\).\{20\}/\t/g; s/ //g; p}' \
    | egrep -v '^\W*ID_' \
    | gawk -n '{ printf("%20s\t0x%04x\t0x%04x\t0x%04x\n", $1, $2, $3, $4); }'
echo -e "\e[0m"


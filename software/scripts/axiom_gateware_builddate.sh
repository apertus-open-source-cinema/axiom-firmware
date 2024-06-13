#!/bin/bash

# check if axiom_start.sh has been started already, otherwise accessing gateware registers will crash the system
FILE=/tmp/axiom.started
if [[ -f "$FILE" ]]; then
    python3 axiom_convert_timestamp.py $(axiom_fil_regi 1)
else
	echo "axiom_start.sh seems to not have been executed yet so accessing gateware registers would crash the system. -> exiting"
    exit 1
fi


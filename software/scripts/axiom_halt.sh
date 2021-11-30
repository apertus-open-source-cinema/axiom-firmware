#!/bin/bash

# SPDX-FileCopyrightText: © 2017 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

if [ "$EUID" -ne 0 ]
  then echo "please run as root, 'sudo axiom_halt.sh'"
  exit
fi

# running axiom_halt.sh twice or once if the service isnt actually running will crash the camera, this should prevent that from happening
FILE=/tmp/axiom.started
if [[ ! -f "$FILE" ]]; then
    echo "AXIOM service does not seem to be running."
    exit
fi

axiom_fil_reg 11 0xFC01F010	# block writer

axiom_mimg -a -P 0
axiom_mimg -a -o -P 0

axiom_gen_reg 11 0x0004F010	# block reader
axiom_fil_reg 15 0x10
axiom_gen_reg 11 0x10

# running axiom_start.sh twice will crash the camera, this should prevent that from happening
rm /tmp/axiom.started


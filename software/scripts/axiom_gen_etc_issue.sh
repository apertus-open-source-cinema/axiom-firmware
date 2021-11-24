#!/bin/bash

# SPDX-FileCopyrightText: © 2019 Jaro Habiger <jarohabiger@googlemail.com>
# SPDX-License-Identifier: GPL-3.0-only

echo "apertus axiom $(cat /etc/hostname) running Arch Linux ARM [\m]" > /etc/issue
echo "Kernel \r" >> /etc/issue
echo "Build $(cd /opt/axiom-firmware; git describe --always --abbrev=8 --dirty)" >> /etc/issue
echo "Network (ipv4) \4 [$(cat /sys/class/net/eth0/address)]" >> /etc/issue
echo "Serial console on \l [\b baud]" >> /etc/issue
echo "initial login is \e{lightgreen}operator\e{reset} with password \e{lightgreen}axiom\e{reset}." >> /etc/issue

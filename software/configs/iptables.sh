#!/bin/sh

# SPDX-FileCopyrightText: © 2019 Jaro Habiger <jarohabiger@googlemail.com>
# SPDX-License-Identifier: GPL-3.0-only

# inserts iptables rules that redirect all http traffic to the camera
# if the ip address is 10.42.0.1 (NetworkManager "shared")
# this is nescessary for the captive portal functionality

if (ip address show dev wlan0 | grep "10.42.0.1"); then 
    iptables -t nat -A PREROUTING -i wlan0 -p tcp ! -d 10.42.0.1 --dport 80  -j DNAT --to 10.42.0.1:81
else
    iptables -t nat -D PREROUTING -i wlan0 -p tcp ! -d 10.42.0.1 --dport 80  -j DNAT --to 10.42.0.1:81
fi

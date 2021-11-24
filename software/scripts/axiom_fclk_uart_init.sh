#!/bin/bash

# SPDX-FileCopyrightText: © 2017 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

[ -e /sys/class/fclk/fclk0 ] || \
    echo fclk0 >/sys/devices/soc0/amba/f8007000.devcfg/fclk_export
[ -e /sys/class/fclk/fclk1 ] || \
    echo fclk1 >/sys/devices/soc0/amba/f8007000.devcfg/fclk_export
[ -e /sys/class/fclk/fclk2 ] || \
    echo fclk2 >/sys/devices/soc0/amba/f8007000.devcfg/fclk_export
[ -e /sys/class/fclk/fclk3 ] || \
    echo fclk3 >/sys/devices/soc0/amba/f8007000.devcfg/fclk_export

echo 100000000 >/sys/class/fclk/fclk0/set_rate	# 100MHz
echo 100000000 >/sys/class/fclk/fclk1/set_rate	# 100MHz
echo 500000000 >/sys/class/fclk/fclk2/set_rate	# 500MHz
echo 500000000 >/sys/class/fclk/fclk3/set_rate	# 500MHz

echo         1 >/sys/class/fclk/fclk0/enable
echo         1 >/sys/class/fclk/fclk1/enable
echo         1 >/sys/class/fclk/fclk2/enable
echo         1 >/sys/class/fclk/fclk3/enable

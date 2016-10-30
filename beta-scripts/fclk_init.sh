#!/bin/sh

# echo fclk0 >/sys/devices/axi.0/f8007000.ps7-dev-cfg/fclk_export
# echo fclk1 >/sys/devices/axi.0/f8007000.ps7-dev-cfg/fclk_export
# echo fclk2 >/sys/devices/axi.0/f8007000.ps7-dev-cfg/fclk_export
# echo fclk3 >/sys/devices/axi.0/f8007000.ps7-dev-cfg/fclk_export

[ -e /sys/class/fclk/fclk0 ] || \
    echo fclk0 >/sys/devices/soc0/axi\@0/f8007000.ps7-dev-cfg/fclk_export
[ -e /sys/class/fclk/fclk1 ] || \
    echo fclk1 >/sys/devices/soc0/axi\@0/f8007000.ps7-dev-cfg/fclk_export
[ -e /sys/class/fclk/fclk2 ] || \
    echo fclk2 >/sys/devices/soc0/axi\@0/f8007000.ps7-dev-cfg/fclk_export
[ -e /sys/class/fclk/fclk3 ] || \
    echo fclk3 >/sys/devices/soc0/axi\@0/f8007000.ps7-dev-cfg/fclk_export

echo 100000000 >/sys/class/fclk/fclk0/set_rate	# 100MHz
echo  10000000 >/sys/class/fclk/fclk1/set_rate	# 10MHz
echo   1000000 >/sys/class/fclk/fclk2/set_rate	# 1MHz
echo 125000000 >/sys/class/fclk/fclk3/set_rate	# 125MHz

echo         1 >/sys/class/fclk/fclk0/enable
echo         1 >/sys/class/fclk/fclk1/enable
echo         1 >/sys/class/fclk/fclk2/enable
echo         1 >/sys/class/fclk/fclk3/enable

#!/bin/sh

cd "${0%/*}"		# change into script dir

. ./i2c.func

VM=(20 10 5 2.5 1.25 0.625 0.3125 0.1563 0.0781 0.0390 0.0195)

PACn=(0x28 0x29 0x2a 0x2c 0x2d 0x48 0x49 0x4a 0x4b 0x4c 0x4d)
MR1v=(0.015 0.015 0.015 0.015 0.015 0.015 0.015 0.015 0.015 0.015 0.015)
MR2v=(0.015 0.015 0.015 0.015 0.015 0.015 0.015 0.015 0.015 0.015 0.015)

VS1l=("ZED_5V"  "HDN"      "HDS"      "RFW_V" "RFE_V" "VCCO_35" "PCIE_IO" "W_VW" "N_VN" "E_VE" "S_VS")
VS2l=("BETA_5V" "PCIE_N_V" "PCIE_S_V" "IOW_V" "IOE_V" "VCCO_13" "VCCO_34" "N_VW" "N_VE" "S_VE" "S_VW")

for i in `seq 1 ${#PACn[*]}`; do n=$[i-1]
  ID="${PACn[$n]}"
  i2c_test $ID || continue

  i2c_set $ID 0x0A 0xFF		# 20ms sample, average 8
  i2c_set $ID 0x0B 0xFF		# 320ms sample, average 8, 80mV
  i2c_set $ID 0x0C 0xFF		# 320ms sample, average 8, 80mV

  VV1i=$[ (`i2c_get $ID 0x11` << 8) | `i2c_get $ID 0x12` ]
  VV2i=$[ (`i2c_get $ID 0x13` << 8) | `i2c_get $ID 0x14` ]

  VV1f=`dc -e "5k $VV1i 20 * 32768 / p"`
  VV2f=`dc -e "5k $VV2i 20 * 32768 / p"`

  VS1i=$[ (`i2c_get $ID 0x0D` << 4) | (`i2c_get $ID 0x0E` >> 4) ]
  VS2i=$[ (`i2c_get $ID 0x0F` << 4) | (`i2c_get $ID 0x10` >> 4) ]

  [ $VS1i -ge 2048 ] && VS1v=$[ $VS1i - 4096 ] || VS1v=$VS1i
  [ $VS2i -ge 2048 ] && VS2v=$[ $VS2i - 4096 ] || VS2v=$VS2i

  VS1f=`dc -e "5k ${VS1v/-/_} 80.0 * 2048 / p"`
  VS2f=`dc -e "5k ${VS2v/-/_} 80.0 * 2048 / p"`

  VA1f=`dc -e "5k ${VS1f/-/_} ${MR1v[$n]} / p"`
  VA2f=`dc -e "5k ${VS2f/-/_} ${MR2v[$n]} / p"`

  printf "%-14.14s\t%6.4f V [%4x] \t%+8.4f mV [%3.3x]  %+8.2f mA\n" \
	"${VS1l[$n]}" $VV1f $VV1i $VS1f $VS1i $VA1f
  printf "%-14.14s\t%6.4f V [%4x] \t%+8.4f mV [%3.3x]  %+8.2f mA\n" \
	"${VS2l[$n]}" $VV2f $VV2i $VS2f $VS2i $VA2f
done


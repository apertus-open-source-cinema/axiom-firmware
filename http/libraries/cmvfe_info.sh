#!/bin/sh

TEMP28=`cat /sys/class/i2c-adapter/i2c-1/1-0028/temp1_input`
TEMP4B=`cat /sys/class/i2c-adapter/i2c-1/1-004b/temp1_input`
TEMP4F=`cat /sys/class/i2c-adapter/i2c-1/1-004f/temp1_input`

V18B28=`cat /sys/class/i2c-adapter/i2c-1/1-0028/in1_input`
V18A28=`cat /sys/class/i2c-adapter/i2c-1/1-0028/in2_input`
V30X28=`cat /sys/class/i2c-adapter/i2c-1/1-0028/in4_input`
V33X28=`cat /sys/class/i2c-adapter/i2c-1/1-0028/in5_input`

printf "Board Temperature : %2d.%02dC\n" $(( TEMP28 / 1000 )) $(( (TEMP28 % 1000) / 10 ))
printf "Below Sensor Temp : %2d.%02dC\n" $(( TEMP4B / 1000 )) $(( (TEMP4B % 1000) / 10 ))
printf "                    %2d.%02dC\n" $(( TEMP4F / 1000 )) $(( (TEMP4F % 1000) / 10 ))

printf "Voltage 1V8A      : %1d.%03dV\n" $(( V18A28 / 1000 )) $(( V18A28 % 1000 ))
printf "Voltage 1V8B      : %1d.%03dV\n" $(( V18B28 / 1000 )) $(( V18B28 % 1000 ))
printf "Voltage 3V0       : %1d.%03dV\n" $(( V30X28 * 2 / 1000 )) $(( V30X28 * 2 % 1000 ))
printf "Voltage 3V3       : %1d.%03dV\n" $(( V33X28 * 2 / 1000 )) $(( V33X28 * 2 % 1000 ))

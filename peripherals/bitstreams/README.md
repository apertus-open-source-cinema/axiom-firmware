<!--
SPDX-FileCopyrightText: © 2020 Robin Ole Heinemann <robin.ole.heinemann@gmail.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# bitstreams
Unfortunately building the gateware in a automated fashion is currently quite hard, as it needs vivado.
Until nextpnr, yosys and ghdl are ready to build this gateware or we have switched to a nmigen based gateware, this folder will hold verious perbuilt bitstreams

## contents
### micro_main.bit
This bitstream is for the AXIOM Micro r2, it reads out the AR0330 sensor and writes the sensor into a ringbuffer in the DDR3 RAM connected to the zynq. From there the data can sent away over ethernet.
### cmv_hdmi3_dual_60.bit
This bitstream is for the AXIOM Beta, it reads out the cmv12k sensor and outputs 1920x1080@60Hz HDMI on both plugin modules.
### cmv_hdmi3_dual_30.bit
This bitstream is for the AXIOM Beta, it reads out the cmv12k sensor and outputs 1920x1080@30Hz HDMI on both plugin modules.
### icsp.bit, check_pin10.bit, check_pin20.bit
These bitstreams are used for the initial bringup of a AXIOM Beta.

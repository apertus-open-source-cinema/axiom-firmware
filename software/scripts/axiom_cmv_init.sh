#!/bin/bash

# SPDX-FileCopyrightText: © 2015 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

# defaults
axiom_cmv_reg  0       0
axiom_cmv_reg  1    3072

for n in `seq 2 65`; do axiom_cmv_reg $n 0; done

axiom_cmv_reg  66      0
axiom_cmv_reg  67      1


axiom_cmv_reg  68      9	# Color[3] = 1, Bin_en[2] = 0, Sub_en[1] = 0, Color[0] = 1


axiom_cmv_reg  69      2	# Flip in Y
# axiom_cmv_reg  69      0	# No Flipping

axiom_cmv_reg  70      0

axiom_cmv_reg  71   1536
axiom_cmv_reg  72      0
axiom_cmv_reg  73   1536
axiom_cmv_reg  74      0

axiom_cmv_reg  75      0
axiom_cmv_reg  76      0
axiom_cmv_reg  77      0
axiom_cmv_reg  78      0

axiom_cmv_reg  79      1


axiom_cmv_reg  80	     1	# single frame
axiom_cmv_reg  81      1	# 16 outputs on each side


#axiom_cmv_reg  87   1824	# Dark Level Offset Bottom
axiom_cmv_reg  87   1910	# Dark Level Offset Bottom
#axiom_cmv_reg  88   1824	# Dark Level Offset Top
axiom_cmv_reg  88   1910	# Dark Level Offset Top


#axiom_cmv_reg  89     85
axiom_cmv_reg  89 35477 #Black_col_en[15], Training_pattern[11:0]


axiom_cmv_reg  90 0x5555	# disable unused LVDS
axiom_cmv_reg  91 0x5555	# disable unused LVDS
axiom_cmv_reg  92 0x5555	# disable unused LVDS
axiom_cmv_reg  93 0x5555	# disable unused LVDS
axiom_cmv_reg  94    0x7	# enable in/out/ctrl


axiom_cmv_reg  95 0xFFFF
axiom_cmv_reg  96 0xFFFF
axiom_cmv_reg  97      0
axiom_cmv_reg  98  39433 	# Datasheet default: 34952, 12bit normal mode: 39433
axiom_cmv_reg  99  34956 # was 34952, Datasheet V2.11 Register Change Suggestions
axiom_cmv_reg 100      0
axiom_cmv_reg 101      0
axiom_cmv_reg 102    8302	# Datasheet V2.7 from 18/12/2014 suggests to change Register 102 to 8302 to decrease column PFN 
axiom_cmv_reg 103   4032
axiom_cmv_reg 104     64
axiom_cmv_reg 105   8256
axiom_cmv_reg 106   8256
axiom_cmv_reg 107   10462	# as suggested by Datsheet 7.7.4 Clock Speed with 12 bit mode and 250MHz Clk
axiom_cmv_reg 108   12381	
axiom_cmv_reg 109  14448  # Datasheet 7.7.3
axiom_cmv_reg 110 12368 # Datasheet Fixed Value: 12368
axiom_cmv_reg 111  34952
axiom_cmv_reg 112    277	# Datasheet V2.6 from 22/08/2014 suggests Reg 112 = 277 


axiom_cmv_reg 115      0	# Unity Gain PGA_div[3], PGA_gain[2:0]
# axiom_cmv_reg 115      1	# Analog Gain 2x PGA_div[3], PGA_gain[2:0]
# axiom_cmv_reg 115      3	# Analog Gain 3x PGA_div[3], PGA_gain[2:0]
# axiom_cmv_reg 115        7	# Analog Gain 4x PGA_div[3], PGA_gain[2:0]


axiom_cmv_reg 116    0x3FF	# Adc Range Slope
axiom_cmv_reg 117        1	# Digital Gain


# axiom_cmv_reg 118      2	# 8bit
# axiom_cmv_reg 118      1	# 10bit
axiom_cmv_reg 118      0	# 12bit


axiom_cmv_reg 119      0
axiom_cmv_reg 120      9
axiom_cmv_reg 121      1
axiom_cmv_reg 122     32
axiom_cmv_reg 123      0
axiom_cmv_reg 124     15
axiom_cmv_reg 125      2
axiom_cmv_reg 126    770


# normal 12bit mode 16 outputs on each side, see Datasheet 7.7.3
axiom_cmv_reg  82   1822
axiom_cmv_reg  83   5897
axiom_cmv_reg  84    257
axiom_cmv_reg  85    257
axiom_cmv_reg  86    257
axiom_cmv_reg  98  39433

axiom_cmv_reg 113    542
axiom_cmv_reg 114    200

# read temperature
axiom_cmv_reg 127

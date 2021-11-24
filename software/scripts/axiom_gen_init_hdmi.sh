#!/bin/bash

# SPDX-FileCopyrightText: © 2021 Herbert Poetzl <herbert@13thfloor.at>
# SPDX-License-Identifier: GPL-2.0-only

case $1 in
  1080p60|1080p30)
    #   Total	Active	Front	Sync	Back
    H=(	2200	1920	  88	  44	 148 )
    V=( 1125	1080	   4	   5	  36 )
    D=(   32 )
    ;;

  1080p50|1080p25)
    #   Total	Active	Front	Sync	Back
    H=(	2640	1920	 528	  44	 148 )
    V=( 1125	1080	   4	   5	  36 )
    D=(   32 )
    ;;

  1080p48|1080p24)
    #   Total	Active	Front	Sync	Back
    H=(	2750	1920	 638	  44	 148 )
    V=( 1125	1080	   4	   5	  36 )
    D=(   32 )
    ;;

  2048x1080p60)
    #   Total	Active	Front	Sync	Back
    H=(	2200	2048	  56	  44	  52 )
    V=( 1125	1080	   4	   5	  36 )
    D=(   32 )
    ;;
	
  2048x1080p50)
    #   Total	Active	Front	Sync	Back
    H=(	2640	2048	 400	  44	 148 )
    V=( 1125	1080	   4	   5	  36 )
    D=(   32 )
    ;;
esac


# Sync + Back Porch
HAS=$[ ${H[3]} + ${H[4]} ]
VAS=$[ ${V[3]} + ${V[4]} ]

# Active Start + Active
HAE=$[ $HAS + ${H[1]} ]
VAE=$[ $VAS + ${V[1]} ]

# Sync starts at 0
HSS=0
VSS=0

# Sync ends after Sync
HSE=${H[3]}
VSE=${V[3]}

# Guard is 2 Pixel wide
GRD=$[ $HAS - 2 ]

# Preamble is 8 Pixel
PRE=$[ $GRD - 8 ]

# Data Islands 
TRC=$[ $HAS + ${D[0]} ]

# Guard is 2 Pixel after DI
GDE=$[ $TRC + 2 ]

# Active End + Front Porch 
HT=$[ $HAE + ${H[2]} ]
VT=$[ $VAE + ${V[2]} ]


[ $HT -eq ${H[0]} ] || {
    echo "mismatch horizontal total $HT not equal ${H[0]}"
    exit 1
}

[ $VT -eq ${V[0]} ] || {
    echo "mismatch vertical total $VT not equal ${V[0]}"
    exit 1
}

[ $PRE -gt $HSE ] || {
    echo "preamble $PRE overlaps horizontal sync $HSE"
    exit 1
}


axiom_scn_reg  0 $HT		# total_w
axiom_scn_reg  1 $VT		# total_h
axiom_scn_reg  2 256		# total_f

axiom_scn_reg  4 $HAS		# hdisp_s
axiom_scn_reg  5 $HAE		# hdisp_e
axiom_scn_reg  6 $VAS		# vdisp_s
axiom_scn_reg  7 $VAE		# vdisp_e

axiom_scn_reg  8 $HSS		# hsync_s
axiom_scn_reg  9 $HSE		# hsync_e
axiom_scn_reg 10 $VSS		# vsync_s
axiom_scn_reg 11 $VSE		# vsync_e

axiom_scn_reg 32 $PRE		# pream_s
axiom_scn_reg 33 $GRD		# guard_s
axiom_scn_reg 34 $TRC		# terc4_e
axiom_scn_reg 35 $GDE		# guard_e


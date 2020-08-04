#!/bin/bash
case $1 in
  SHOGUN)
    axiom_scn_reg  0 2200		# total_w
    axiom_scn_reg  1 1125		# total_h
    axiom_scn_reg  2   60		# total_f
    
    axiom_scn_reg  4  262		# hdisp_s
    axiom_scn_reg  5 2182		# hdisp_e
    axiom_scn_reg  6   45		# vdisp_s
    axiom_scn_reg  7 1125		# vdisp_e

    axiom_scn_reg  8    0		# hsync_s
    axiom_scn_reg  9 2100		# hsync_e
    axiom_scn_reg 10    4		# vsync_s
    axiom_scn_reg 11    9		# vsync_e

    axiom_scn_reg 32  252		# pream_s
    axiom_scn_reg 33  260		# guard_s
    axiom_scn_reg 34  294		# terc4_e
    axiom_scn_reg 35  296		# guard_e
    ;;

  1080p60|1080p30)
    axiom_scn_reg  0 2200		# total_w
    axiom_scn_reg  1 1125		# total_h
    axiom_scn_reg  2   60		# total_f
    
    axiom_scn_reg  4  262		# hdisp_s
    axiom_scn_reg  5 2182		# hdisp_e
    axiom_scn_reg  6   45		# vdisp_s
    axiom_scn_reg  7 1125		# vdisp_e

    axiom_scn_reg  8   88		# hsync_s
    axiom_scn_reg  9  138		# hsync_e
    axiom_scn_reg 10    4		# vsync_s
    axiom_scn_reg 11    9		# vsync_e

    axiom_scn_reg 32  252		# pream_s
    axiom_scn_reg 33  260		# guard_s
    axiom_scn_reg 34  326		# terc4_e
    axiom_scn_reg 35  328		# guard_e
    ;;

  1080p50|1080p25)
    axiom_scn_reg  0 2640		# total_w
    axiom_scn_reg  1 1125		# total_h
    axiom_scn_reg  2   60		# total_f
    
    axiom_scn_reg  4  704		# hdisp_s
    axiom_scn_reg  5 2624		# hdisp_e
    axiom_scn_reg  6   45		# vdisp_s
    axiom_scn_reg  7 1125		# vdisp_e

    axiom_scn_reg  8  528		# hsync_s
    axiom_scn_reg  9  572		# hsync_e
    axiom_scn_reg 10    4		# vsync_s
    axiom_scn_reg 11    9		# vsync_e

    axiom_scn_reg 32  694		# pream_s
    axiom_scn_reg 33  702		# guard_s
    axiom_scn_reg 34  726		# terc4_e
    axiom_scn_reg 35  728		# guard_e
    ;;

  1080p24)
    axiom_scn_reg  0 2750		# total_w
    axiom_scn_reg  1 1125		# total_h
    axiom_scn_reg  2   60		# total_f
    
    axiom_scn_reg  4  814		# hdisp_s
    axiom_scn_reg  5 2734		# hdisp_e
    axiom_scn_reg  6   45		# vdisp_s
    axiom_scn_reg  7 1125		# vdisp_e

    axiom_scn_reg  8  638		# hsync_s
    axiom_scn_reg  9  682		# hsync_e
    axiom_scn_reg 10    4		# vsync_s
    axiom_scn_reg 11    9		# vsync_e
    ;;

  SWIT|SWIT@60|DEEP)
    axiom_scn_reg  0 2200
    axiom_scn_reg  1 1125
    axiom_scn_reg  2   60
    
    axiom_scn_reg  8 2000
    axiom_scn_reg  9 2044
    axiom_scn_reg 10    0
    axiom_scn_reg 11    5

    axiom_disp_init.sh 15 41 1920 1080
    ;;

  SWIT@50|1080p50)
    axiom_scn_reg  0 2640
    axiom_scn_reg  1 1125
    axiom_scn_reg  2   60
    
    axiom_scn_reg  8 2492
    axiom_scn_reg  9 2536
    axiom_scn_reg 10    0
    axiom_scn_reg 11    5

    axiom_disp_init.sh 15 41 1920 1080
    ;;
esac


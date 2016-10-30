#!/bin/sh

cd "${0%/*}"            # change into script dir

. ./hdmi.func

case $1 in
  SHOGUN)
    scn_reg  0 2200		# total_w
    scn_reg  1 1125		# total_h
    scn_reg  2   60		# total_f
    
    scn_reg  4  262		# hdisp_s
    scn_reg  5 2182		# hdisp_e
    scn_reg  6   45		# vdisp_s
    scn_reg  7 1125		# vdisp_e

    scn_reg  8    0		# hsync_s
    scn_reg  9 2100		# hsync_e
    scn_reg 10    4		# vsync_s
    scn_reg 11    9		# vsync_e

    scn_reg 32  252		# pream_s
    scn_reg 33  260		# guard_s
    scn_reg 34  294		# terc4_e
    scn_reg 35  296		# guard_e
    ;;

  1080p60|1080p30)
    scn_reg  0 2200		# total_w
    scn_reg  1 1125		# total_h
    scn_reg  2   60		# total_f
    
    scn_reg  4  262		# hdisp_s
    scn_reg  5 2182		# hdisp_e
    scn_reg  6   45		# vdisp_s
    scn_reg  7 1125		# vdisp_e

    scn_reg  8   88		# hsync_s
    scn_reg  9  138		# hsync_e
    scn_reg 10    4		# vsync_s
    scn_reg 11    9		# vsync_e

    scn_reg 32  252		# pream_s
    scn_reg 33  260		# guard_s
    scn_reg 34  326		# terc4_e
    scn_reg 35  328		# guard_e
    ;;

  1080p50|1080p25)
    scn_reg  0 2640		# total_w
    scn_reg  1 1125		# total_h
    scn_reg  2   60		# total_f
    
    scn_reg  4  704		# hdisp_s
    scn_reg  5 2624		# hdisp_e
    scn_reg  6   45		# vdisp_s
    scn_reg  7 1125		# vdisp_e

    scn_reg  8  528		# hsync_s
    scn_reg  9  572		# hsync_e
    scn_reg 10    4		# vsync_s
    scn_reg 11    9		# vsync_e

    scn_reg 32  694		# pream_s
    scn_reg 33  702		# guard_s
    scn_reg 34  726		# terc4_e
    scn_reg 35  728		# guard_e
    ;;

  1080p24)
    scn_reg  0 2750		# total_w
    scn_reg  1 1125		# total_h
    scn_reg  2   60		# total_f
    
    scn_reg  4  814		# hdisp_s
    scn_reg  5 2734		# hdisp_e
    scn_reg  6   45		# vdisp_s
    scn_reg  7 1125		# vdisp_e

    scn_reg  8  638		# hsync_s
    scn_reg  9  682		# hsync_e
    scn_reg 10    4		# vsync_s
    scn_reg 11    9		# vsync_e
    ;;

  SWIT|SWIT@60|DEEP)
    scn_reg  0 2200
    scn_reg  1 1125
    scn_reg  2   60
    
    scn_reg  8 2000
    scn_reg  9 2044
    scn_reg 10    0
    scn_reg 11    5

    ./disp_init.sh 15 41 1920 1080
    ;;

  SWIT@50|1080p50)
    scn_reg  0 2640
    scn_reg  1 1125
    scn_reg  2   60
    
    scn_reg  8 2492
    scn_reg  9 2536
    scn_reg 10    0
    scn_reg 11    5

    ./disp_init.sh 15 41 1920 1080
    ;;
esac


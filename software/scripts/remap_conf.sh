#!/bin/bash

. ./hdmi.func

C0=12
C1=13
C2=14
C3=15

case "$1" in

  CMV)
    gen_reg $C0 0x394E93E4
    gen_reg $C1 0x39C9E1E4
    gen_reg $C2 0x93D2E1E4
    ;;

  CMVi)
    gen_reg $C0 0x394E93E4
    gen_reg $C1 0x39C9E1E4
    gen_reg $C2 0x93D2E1E4
    ;;

  BGGR|DEEP|ATOMOS|1080p60|1080p50|1080p24) 
    gen_reg $C0 0xE4E4E4E4
    gen_reg $C1 0xE4E4E4E4
    gen_reg $C2 0xE4E4E4E4
    ;;

  RGGB|SWIT) 
    gen_reg $C0 0x1B1B1B1B
    gen_reg $C1 0x1B1B1B1B
    gen_reg $C2 0x1B1B1B1B
    ;;

  REV) 
    gen_reg $C0 0xE4E4E4E4
    gen_reg $C1 0x4E4E4E4E
    gen_reg $C2 0xE4E4E4E4
    ;;

  INV) 
    gen_reg $C0 0x1B1B1B1B
    gen_reg $C1 0x71717171
    gen_reg $C2 0x1B1B1B1B
    ;;

  LSB) 
    gen_reg $C0 0xE4E4E4E4
    gen_reg $C1 0xE4E4E4E4
    gen_reg $C2 0x1B1B1B1B
    ;;

  *)
    gen_reg $C0 0x1B1B1B1B
    gen_reg $C1 0x1B1B1B1B
    gen_reg $C2 0x1B1B1B1B
    ;;

esac

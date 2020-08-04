#!/bin/bash
C0=12
C1=13
C2=14
C3=15

case "$1" in

  CMV)
    axiom_gen_reg $C0 0x394E93E4
    axiom_gen_reg $C1 0x39C9E1E4
    axiom_gen_reg $C2 0x93D2E1E4
    ;;

  CMVi)
    axiom_gen_reg $C0 0x394E93E4
    axiom_gen_reg $C1 0x39C9E1E4
    axiom_gen_reg $C2 0x93D2E1E4
    ;;

  BGGR|DEEP|ATOMOS|1080p60|1080p50|1080p24) 
    axiom_gen_reg $C0 0xE4E4E4E4
    axiom_gen_reg $C1 0xE4E4E4E4
    axiom_gen_reg $C2 0xE4E4E4E4
    ;;

  RGGB|SWIT) 
    axiom_gen_reg $C0 0x1B1B1B1B
    axiom_gen_reg $C1 0x1B1B1B1B
    axiom_gen_reg $C2 0x1B1B1B1B
    ;;

  REV) 
    axiom_gen_reg $C0 0xE4E4E4E4
    axiom_gen_reg $C1 0x4E4E4E4E
    axiom_gen_reg $C2 0xE4E4E4E4
    ;;

  INV) 
    axiom_gen_reg $C0 0x1B1B1B1B
    axiom_gen_reg $C1 0x71717171
    axiom_gen_reg $C2 0x1B1B1B1B
    ;;

  LSB) 
    axiom_gen_reg $C0 0xE4E4E4E4
    axiom_gen_reg $C1 0xE4E4E4E4
    axiom_gen_reg $C2 0x1B1B1B1B
    ;;

  *)
    axiom_gen_reg $C0 0x1B1B1B1B
    axiom_gen_reg $C1 0x1B1B1B1B
    axiom_gen_reg $C2 0x1B1B1B1B
    ;;

esac

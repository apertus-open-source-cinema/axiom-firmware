#!/bin/sh

cd "${0%/*}"            # change into script dir

. ./hdmi.func

FIXM=$(( 1 << 8 ))
FIXO=$(( 1 << 12 ))

A0=`dc -e "5k ${1:-0} $FIXM * p" | sed 's/[.].*$//'`
A1=`dc -e "5k ${2:-0} $FIXM * p" | sed 's/[.].*$//'`
A2=`dc -e "5k ${3:-0} $FIXM * p" | sed 's/[.].*$//'`
A3=`dc -e "5k ${4:-0} $FIXM * p" | sed 's/[.].*$//'`
A4=`dc -e "5k ${17:-0} $FIXO * p" | sed 's/[.].*$//'`

B0=`dc -e "5k ${5:-0} $FIXM * p" | sed 's/[.].*$//'`
B1=`dc -e "5k ${6:-0} $FIXM * p" | sed 's/[.].*$//'`
B2=`dc -e "5k ${7:-0} $FIXM * p" | sed 's/[.].*$//'`
B3=`dc -e "5k ${8:-0} $FIXM * p" | sed 's/[.].*$//'`
B4=`dc -e "5k ${18:-0} $FIXO * p" | sed 's/[.].*$//'`

C0=`dc -e "5k ${9:-0} $FIXM * p" | sed 's/[.].*$//'`
C1=`dc -e "5k ${10:-0} $FIXM * p" | sed 's/[.].*$//'`
C2=`dc -e "5k ${11:-0} $FIXM * p" | sed 's/[.].*$//'`
C3=`dc -e "5k ${12:-0} $FIXM * p" | sed 's/[.].*$//'`
C4=`dc -e "5k ${19:-0} $FIXO * p" | sed 's/[.].*$//'`

D0=`dc -e "5k ${13:-0} $FIXM * p" | sed 's/[.].*$//'`
D1=`dc -e "5k ${14:-0} $FIXM * p" | sed 's/[.].*$//'`
D2=`dc -e "5k ${15:-0} $FIXM * p" | sed 's/[.].*$//'`
D3=`dc -e "5k ${16:-0} $FIXM * p" | sed 's/[.].*$//'`
D4=`dc -e "5k ${20:-0} $FIXO * p" | sed 's/[.].*$//'`

min=0; max=0
for n in $A1 $A2 $A3 $A4 $B1 $B2 $B3 $B4 $C1 $C2 $C3 $C4 $D1 ; do
    [ $n -lt $min ] && min=$n
    [ $n -gt $max ] && max=$n
done

mat_reg 0 $(( A0 & 0xFFFF ))
mat_reg 1 $(( A1 & 0xFFFF ))
mat_reg 2 $(( A2 & 0xFFFF ))
mat_reg 3 $(( A3 & 0xFFFF ))

mat_reg 4 $(( B0 & 0xFFFF ))
mat_reg 5 $(( B1 & 0xFFFF ))
mat_reg 6 $(( B2 & 0xFFFF ))
mat_reg 7 $(( B3 & 0xFFFF ))

mat_reg 8 $(( C0 & 0xFFFF ))
mat_reg 9 $(( C1 & 0xFFFF ))
mat_reg 10 $(( C2 & 0xFFFF ))
mat_reg 11 $(( C3 & 0xFFFF ))

mat_reg 12 $(( D0 & 0xFFFF ))
mat_reg 13 $(( D1 & 0xFFFF ))
mat_reg 14 $(( D2 & 0xFFFF ))
mat_reg 15 $(( D3 & 0xFFFF ))

mat_reg 32 $(( A4 & 0xFFFF ))
mat_reg 33 $(( B4 & 0xFFFF ))
mat_reg 34 $(( C4 & 0xFFFF ))
mat_reg 35 $(( D4 & 0xFFFF ))

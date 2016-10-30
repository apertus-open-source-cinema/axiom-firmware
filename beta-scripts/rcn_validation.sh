#!/bin/bash

./rcn_clear.py
./cmv_snap3 -2 -b -r -e 10ms > dark-check-1.raw12 

./rcn_darkframe.py darkframe-x1.pgm
./cmv_snap3 -2 -b -r -e 10ms > dark-check-2.raw12 

./raw2dng --no-darkframe --check-darkframe dark-check-1.raw12
./raw2dng --no-darkframe --check-darkframe dark-check-2.raw12

rm dark-check-1.raw12 
rm dark-check-2.raw12

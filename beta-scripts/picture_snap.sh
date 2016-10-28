#!/bin/bash
#
# Capture an image with a unique name
#

PARAMS=$1
IMAGENAME=`date +%Y%m%d_%H%M%S`
mkdir -p /opt/picture-snap/$IMAGENAME

# Stop HDMI live stream so it does not interfere with image snapping
fil_reg 15 0

#capture frame
./cmv_snap3 -e $PARAMS -2 -r -b > /opt/picture-snap/$IMAGENAME/$IMAGENAME.raw12

#convert to DNG
./raw2dng /opt/picture-snap/$IMAGENAME/$IMAGENAME.raw12 --swap-lines 


# restart HDMI live stream
fil_reg 15 0x01000100

echo /opt/picture-snap/$IMAGENAME/$IMAGENAME.raw12

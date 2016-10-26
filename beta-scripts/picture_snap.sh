#!/bin/bash
#
# Capture an image with a unique name
#

IMAGENAME=`date +%Y%m%d_%H%M%S`
mkdir -p /opt/picture-snap/$IMAGENAME

# Stop HDMI live stream so it does not interfere with image snapping
fil_reg 15 0

#capture frame
./cmv_snap3 -e 10ms -2 -r -b > /opt/picture-snap/$IMAGENAME/$IMAGENAME.raw12
# todo make exposure time dynamic

# restart HDMI live stream
fil_reg 15 0x01000100

echo /opt/picture-snap/$IMAGENAME/$IMAGENAME.raw12

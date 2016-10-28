#!/bin/bash
#
# Capture an image with a unique name
#

PARAMS=$1
IMAGENAME=`date +%Y%m%d_%H%M%S`
mkdir -p /opt/picture-snap/$IMAGENAME
echo /opt/picture-snap/$IMAGENAME/$IMAGENAME.raw12

# Stop HDMI live stream so it does not interfere with image snapping
fil_reg 15 0

#capture frame
./cmv_snap3 -e $PARAMS -2 -r -b > /opt/picture-snap/$IMAGENAME/$IMAGENAME.raw12

#convert to DNG
./raw2dng /opt/picture-snap/$IMAGENAME/$IMAGENAME.raw12 --swap-lines 

#raw develop preview
dcraw -h /opt/picture-snap/$IMAGENAME/$IMAGENAME.DNG

#conert preview to JPG
convert /opt/picture-snap/$IMAGENAME/$IMAGENAME.ppm /opt/picture-snap/$IMAGENAME/$IMAGENAME.jpg

# restart HDMI live stream
fil_reg 15 0x01000100

echo "done!"

#!/bin/bash
#
# Capture an image with a unique name
#

PARAMS=$1
IMAGENAME=`date +%Y%m%d_%H%M%S`
mkdir -p /opt/picture-snap/$IMAGENAME
echo /opt/picture-snap/$IMAGENAME/$IMAGENAME.raw12

# Stop HDMI live stream so it does not interfere with image snapping
axiom_fil_reg 15 0

#capture frame
axiom_snap -e $PARAMS -2 -r -b > /dev/null
axiom_snap -e $PARAMS -2 -r -b > /opt/picture-snap/$IMAGENAME/$IMAGENAME.raw12

echo "raw12 written"

# restart HDMI live stream
axiom_fil_reg 15 0x01000100

#convert to DNG
raw2dng /opt/picture-snap/$IMAGENAME/$IMAGENAME.raw12 --swap-lines

echo "DNG written"

#raw develop preview
dcraw -h /opt/picture-snap/$IMAGENAME/$IMAGENAME.DNG

echo "PPM written"

#conert preview to JPG
convert /opt/picture-snap/$IMAGENAME/$IMAGENAME.ppm /opt/picture-snap/$IMAGENAME/$IMAGENAME.jpg

echo "JPG written"

# md5sum /root/darkframe-x1.pgm >  /opt/picture-snap/$IMAGENAME/$IMAGENAME.meta


echo "all done!"

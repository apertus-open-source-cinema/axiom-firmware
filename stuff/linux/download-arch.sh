#!/bin/bash
#
# download-arch.sh
#  Download ArchLinuxARM
#  (c) 2016, John Kelley <john@kelley.ca>
#  All rights reserved
#  Subject to 3-clause BSD License

URL_BASE=http://co.us.mirror.archlinuxarm.org/os/xilinx/
FILENAME=ArchLinuxARM-2016.02-zedboard-rootfs.tar.gz
MD5_FILENAME=${FILENAME}.md5

if [ -f ${FILENAME} ]; then
	MD5=`md5 -q ${FILENAME}`
	REF_MD5=`wget -q -O - ${URL_BASE}${MD5_FILENAME} | awk '{print $1}'`
	if [ $MD5 != $REF_MD5 ]; then
		echo File is corrupt, redownloading
		rm ${FILENAME}
		wget ${URL_BASE}${FILENAME}
	else
		echo Downloaded file is identical to server file
	fi
else
	wget ${URL_BASE}${FILENAME}
fi

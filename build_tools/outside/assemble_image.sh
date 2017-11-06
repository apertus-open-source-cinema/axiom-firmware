#!/bin/bash
echo "starting the build..." | boxes -d parchment
set -e 
set -o pipefail
mkdir -p build
cd build

if ([ ! -f linux-xlnx.git/arch/arm/boot/zImage ] || [ ! -d kernel_modules/ ] || [ ! -f BOOT.bin ] || [ ! -d ROOT.fs/ ]); then
    echo "build the kernel, u-boot and the the rootfs first!"
    exit 1
fi

echo "combine ROOT.fs_kernel_modules into ROOT.fs" | boxes -d parchment
rsync -aK kernel_modules/ ROOT.fs/


echo "create the bootfs" | boxes -d parchment
mkdir -p BOOT.fs
cp linux-xlnx.git/arch/arm/boot/zImage BOOT.fs/
cp BOOT.bin BOOT.fs/
cp ../boot/uEnv.txt BOOT.fs/
cp ../boot/devicetree.dtb BOOT.fs/devicetree.dtb


echo "create the base image structure" | boxes -d parchment
BLKOFFS=$[ 8 ]
BLKSIZE=$[ 8*1024*1024*2 ]
BLKBOOT=$[ 50*1024*2 ]
BLKROOT=$[ BLKSIZE - BLKBOOT - BLKOFFS ]
BLKSEEK=$[ BLKSIZE - 1 ]
BLKOFF2=$[ BLKOFFS + BLKBOOT ]

rm -f IMAGE.dd
dd if=/dev/zero of=IMAGE.dd bs=512 seek=$BLKSEEK count=1

sfdisk -uS IMAGE.dd << EOF
 part1 : start= $BLKOFFS, size= $BLKBOOT, Id=  c
 part2 : start= $BLKOFF2, size= $BLKROOT, Id= 83
 part3 : start=        0, size=        0, Id=  0
 part4 : start=        0, size=        0, Id=  0
EOF

echo "create the boot partition & assamble it into the image" | boxes -d parchment
rm -f BOOT.part
dd if=/dev/zero of=BOOT.part bs=512 seek=$[ BLKBOOT - 1] count=1
mkfs.vfat -n "BOOT" -F 32 BOOT.part $[ BLKBOOT / 2 ]
mcopy -i BOOT.part BOOT.fs/* :: 

dd if=BOOT.part of=IMAGE.dd bs=512 seek=$BLKOFFS count=$BLKBOOT conv=sparse,notrunc


echo "create the root partition & assamble it into the image" | boxes -d parchment
rm -f ROOT.part
dd if=/dev/zero of=ROOT.part bs=512 seek=$[ BLKROOT - 1] count=1
mkfs.ext4 -d ROOT.fs ROOT.part $[ BLKROOT / 2 ]

dd if=ROOT.part of=IMAGE.dd bs=512 seek=$BLKOFF2 count=$BLKROOT conv=sparse,notrunc

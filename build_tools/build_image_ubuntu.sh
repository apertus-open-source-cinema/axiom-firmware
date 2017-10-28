#!/bin/bash
echo "starting the build..." | boxes -d parchment
mkdir -p build
cd build


echo "create the base image structure" | boxes -d parchment
BLKOFFS=$[ 8 ]
BLKSIZE=$[ 8*1024*1024*2 ]
BLKBOOT=$[ 50*1024*2 ]
BLKROOT=$[ 4*1024*1024*2 ]

BLKSEEK=$[ BLKSIZE - 1 ]
BLKPART=$[ BLKSIZE - BLKBOOT - BLKROOT - BLKOFFS ]

BLKOFF2=$[ BLKOFFS + BLKBOOT ]
BLKOFF3=$[ BLKOFF2 + BLKROOT ]

rm -f IMAGE.dd
dd if=/dev/zero of=IMAGE.dd bs=512 seek=$BLKSEEK count=1

sfdisk -uS IMAGE.dd << EOF
 part1 : start= $BLKOFFS, size= $BLKBOOT, Id= c
 part2 : start= $BLKOFF2, size= $BLKROOT, Id=83
 part3 : start= $BLKOFF3, size= $BLKPART, Id=83
 part4 : start=        0, size=        0, Id= 0
EOF


echo "Download archlinuxarm & extract it as rootfs" | boxes -d parchment
mkdir -p ROOT.fs
wget -c --quiet http://archlinuxarm.org/os/ArchLinuxARM-zedboard-latest.tar.gz
tar --warning=no-unknown-keyword -x -C ROOT.fs -f ArchLinuxARM-zedboard-latest.tar.gz


echo "download and build the xillinx linux kernel; install the kernel modules into the rootfs" | boxes -d parchment
BRANCH=xilinx-v2016.4
git clone --branch $BRANCH --depth 1 https://github.com/Xilinx/linux-xlnx.git linux-xlnx.git

ARCH=arm
CROSS=arm-linux-gnueabi-
(cd linux-xlnx.git; git checkout tags/xilinx-v2016.4 -b xilinx-v2016.4 )
(cd linux-xlnx.git; make CROSS_COMPILE=$CROSS ARCH=$ARCH xilinx_zynq_defconfig )
(cd linux-xlnx.git; make CROSS_COMPILE=$CROSS ARCH=$ARCH -j99 )
(cd linux-xlnx.git; make CROSS_COMPILE=$CROSS ARCH=$ARCH zynq-zed.dtb )
(cd linux-xlnx.git; make CROSS_COMPILE=$CROSS ARCH=$ARCH -j99 modules)
(cd linux-xlnx.git; make CROSS_COMPILE=$CROSS ARCH=$ARCH INSTALL_MOD_PATH=../ROOT.fs modules_install )


echo "create the bootfs" | boxes -d parchment
mkdir -p BOOT.fs
cp -va linux-xlnx.git/arch/arm/boot/zImage BOOT.fs/
cp -va linux-xlnx.git/arch/arm/boot/dts/zynq-zed.dtb BOOT.fs/devicetree.dtb


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


echo "download & buid qemu" | boxes -d parchment
git clone https://github.com/Xilinx/qemu.git qemu-xlnx.git

(cd qemu-xlnx.git; git submodule update --init pixman dtc )

(cd qemu-xlnx.git; ./configure --target-list="aarch64-softmmu" --enable-fdt --disable-kvm --disable-xen )
(cd qemu-xlnx.git; make -j$(nproc) )

# to run qemu use the following command:
# qemu-xlnx.git/aarch64-softmmu/qemu-system-aarch64 -M arm-generic-fdt-7series -machine linux=on -serial /dev/null -serial mon:stdio -nographic -dtb BOOT.fs/devicetree.dtb -kernel BOOT.fs/zImage -drive if=sd,format=raw,index=0,file=IMAGE.dd -boot mode=5 -append "root=/dev/mmcblk0p2 ro rootwait rootfstype=ext4" 

#!/bin/bash
echo "starting the build..." | boxes -d parchment
set -e 
set -o pipefail
mkdir -p build
cd build


echo "download and build the xillinx u-boot" | boxes -d parchment
git clone --depth 1 https://github.com/Xilinx/u-boot-xlnx u-boot-xlnx.git

ARCH=arm
CROSS=arm-linux-gnueabi-
(cd u-boot-xlnx.git; patch Makefile ../../boot/u-boot.patch)
(cd u-boot-xlnx.git; yes "" | make CROSS_COMPILE=$CROSS ARCH=$ARCH KCONFIG_CONFIG=../../boot/u-boot.config oldconfig || echo "")
(cd u-boot-xlnx.git; make CROSS_COMPILE=$CROSS ARCH=$ARCH KCONFIG_CONFIG=../../boot/u-boot.config -j$(nproc))
(cd u-boot-xlnx.git; make CROSS_COMPILE=$CROSS ARCH=$ARCH KCONFIG_CONFIG=../../boot/u-boot.config u-boot.elf)


echo "download and build zynq-mkbootimage" | boxes -d parchment
git clone --depth 1 https://github.com/antmicro/zynq-mkbootimage zynq-mkbootimage.git

(cd zynq-mkbootimage.git; make -j$(nproc))


echo "build BOOT.bin with zynq-mkbootimage" | boxes -d parchment
cp ../boot/boot.bif .
cp ../boot/fsbl.elf .
cp u-boot-xlnx.git/u-boot.elf .
zynq-mkbootimage.git/mkbootimage boot.bif BOOT.bin

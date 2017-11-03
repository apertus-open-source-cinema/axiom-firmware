#!/bin/bash
echo "starting the build..." | boxes -d parchment
set -e 
set -o pipefail
mkdir -p build
cd build


echo "download and build the xillinx linux kernel; install the kernel modules into the rootfs" | boxes -d parchment
BRANCH=xilinx-v2016.4
git clone --branch $BRANCH --depth 1 https://github.com/Xilinx/linux-xlnx.git linux-xlnx.git

ARCH=arm
CROSS=arm-linux-gnueabi-
(cd linux-xlnx.git; git checkout tags/xilinx-v2016.4 -b xilinx-v2016.4 )
echo "CONFIG_BPF_SYSCALL=y" >> linux-xlnx.git/arch/arm/configs/xilinx_zynq_defconfig
(cd linux-xlnx.git; make CROSS_COMPILE=$CROSS ARCH=$ARCH xilinx_zynq_defconfig )
(cd linux-xlnx.git; make CROSS_COMPILE=$CROSS ARCH=$ARCH -j$(nproc) )
(cd linux-xlnx.git; make CROSS_COMPILE=$CROSS ARCH=$ARCH zynq-zed.dtb )
(cd linux-xlnx.git; make CROSS_COMPILE=$CROSS ARCH=$ARCH -j$(nproc) modules)
(cd linux-xlnx.git; make CROSS_COMPILE=$CROSS ARCH=$ARCH INSTALL_MOD_PATH=../ROOT.fs_kernel_modules modules_install )


echo "download the BOOT.bin" | boxes -d parchment
# for now, we just download a prebuild binary due to the lack of build instructions
# TODO: really build u-boot from source
wget -c -nv http://vserver.13thfloor.at/Stuff/JARHAB/boot.bin


echo "create the bootfs" | boxes -d parchment
mkdir -p BOOT.fs
cp -va linux-xlnx.git/arch/arm/boot/zImage BOOT.fs/zImage
cp ../boot/devicetree.dtb BOOT.fs/devicetree.dtb
cp boot.bin BOOT.fs/BOOT.bin
cp ../boot/uEnv.txt BOOT.fs/uEnv.txt

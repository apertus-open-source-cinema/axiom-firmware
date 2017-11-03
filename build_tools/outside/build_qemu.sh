#!/bin/bash
echo "starting the build..." | boxes -d parchment
set -e 
set -o pipefail
mkdir -p build
cd build


echo "download & buid qemu" | boxes -d parchment
git clone https://github.com/Xilinx/qemu.git qemu-xlnx.git

(cd qemu-xlnx.git; git submodule update --init pixman dtc )

(cd qemu-xlnx.git; ./configure --target-list="aarch64-softmmu" --enable-fdt --disable-kvm --disable-xen )
(cd qemu-xlnx.git; make -j$(nproc) )

# to run qemu use the following command:
# qemu-xlnx.git/aarch64-softmmu/qemu-system-aarch64 -M arm-generic-fdt-7series -machine linux=on -serial /dev/null -serial mon:stdio -nographic -dtb BOOT.fs/devicetree.dtb -kernel BOOT.fs/zImage -drive if=sd,format=raw,index=0,file=IMAGE.dd -boot mode=5 -append "root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4"

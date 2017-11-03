#!/bin/bash
echo "starting the build..." | boxes -d parchment
set -e 
set -o pipefail
mkdir -p build
cd build


echo "download archlinuxarm & extract it as rootfs" | boxes -d parchment
mkdir -p ROOT.fs
wget -c -nv http://archlinuxarm.org/os/ArchLinuxARM-zedboard-latest.tar.gz
tar --warning=no-unknown-keyword -x -C ROOT.fs -f ArchLinuxARM-zedboard-latest.tar.gz


echo "coppy the beta firmware into the /opt/beta-software inside the rootfs" | boxes -d parchment
mkdir -p ROOT.fs/opt/beta-software
rsync -a ../ --exclude=build ROOT.fs/opt/beta-software

echo "chroot inside the rootfs and do the inside install" | boxes -d parchment
mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc || echo "binfmt_misc already loaded"
update-binfmts --enable qemu-aarch64
update-binfmts --enable qemu-arm

mount --rbind ROOT.fs/ ROOT.fs/
mount -t proc /proc ROOT.fs/proc
mount -o bind /dev ROOT.fs/dev
mount -o bind /dev/pts ROOT.fs/dev/pts
mount -o bind /sys ROOT.fs/sys
cp $(which qemu-arm-static) ROOT.fs/usr/bin
cp $(which qemu-aarch64-static) ROOT.fs/usr/bin

chroot ROOT.fs /opt/beta-software/build_tools/inside/install.sh

umount ROOT.fs/sys
umount ROOT.fs/dev/pts
umount ROOT.fs/dev/
umount ROOT.fs/proc
umount ROOT.fs/

#!/bin/bash
# this script is called from the docker-make.sh script and sets up everything in the 
# docker container & executes make

stty cols $COLUMNS rows $LINES;

# this is a stupid hack to work around this bug: https://bugs.launchpad.net/qemu/+bug/1805913
mkdir -p build/root.fs
if [ ! -z $CI ]; then
    mount -t tmpfs tmpfs build/root.fs
    echo "WARNING: building rootfs in ramdisk; incremental builds suffer"
else
    if [ ! -f build/root.fs.loopback.img ]; then
        truncate -s 4G build/root.fs.loopback.img
        mkfs.btrfs build/root.fs.loopback.img
    fi
    losetup -d /dev/loop0
    losetup /dev/loop0 build/root.fs.loopback.img
    mount /dev/loop0 build/root.fs
fi

make -f makefiles/host/main.mk -I makefiles/host -j $(nproc) $*
umount build/root.fs
losetup -d /dev/loop0
#!/bin/bash
# This script is only meant to be executed within the makefiles. it modifies the image to be able to run 
# a user specified command in a changeroot.

set -xeuo pipefail

# needed for the binfmt interpreter for arm
cp -f $(which qemu-arm-static) build/root.fs/usr/bin
cp -f $(which qemu-aarch64-static) build/root.fs/usr/bin

# mount the needed system filesystems
mount -t proc /proc build/root.fs/proc
mount -o bind /dev build/root.fs/dev
mount -o bind /dev/pts build/root.fs/dev/pts
mount -o bind /sys build/root.fs/sys

# register binfmt for arm emulation
mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc || echo "binfmt_misc already loaded"
update-binfmts --enable qemu-aarch64
update-binfmts --enable qemu-arm

# change the resolv conf. systemd is not running in chroot.
[ -f build/root.fs/etc/resolv.conf.bak ] || readlink -v build/root.fs/etc/resolv.conf > build/root.fs/etc/resolv.conf.bak
unlink build/root.fs/etc/resolv.conf
echo "nameserver 185.121.177.177" > build/root.fs/etc/resolv.conf

# use local package cache
rm -rf build/root.fs/var/cache/pacman/*
mkdir -p build/pacman-cache/
mount -o bind build/pacman-cache/ build/root.fs/var/cache/pacman/


chroot build/root.fs $*

# undo the changes, and reset the image to work on hardware again.
ln -sf "$(cat build/root.fs/etc/resolv.conf.bak)" build/root.fs/etc/resolv.conf
rm -f build/root.fs/usr/bin/qemu-arm-static build/root.fs/usr/bin/qemu-aarch64-static

# unmount (allow fail)
umount build/root.fs/var/cache/pacman/pkg/ || true
umount build/root.fs/sys || true
umount build/root.fs/dev/pts || true
umount build/root.fs/dev/ || true
umount build/root.fs/proc || true
# (
#     true
# ) > /dev/null 2>&1

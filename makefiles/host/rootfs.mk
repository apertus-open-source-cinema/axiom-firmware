build/root.fs/etc/motd: $(shell find software/) $(shell find makefiles/in_chroot/) build/root.fs/opt/axiom-firmware
	# really execute the inner steps
	cp -f $$(which qemu-arm-static) build/root.fs/usr/bin
	cp -f $$(which qemu-aarch64-static) build/root.fs/usr/bin

	$(MAKE) -f makefiles/host/main.mk mount

	mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc || echo "binfmt_misc already loaded"
	update-binfmts --enable qemu-aarch64
	update-binfmts --enable qemu-arm

	cat build/root.fs/etc/resolv.conf.bak || readlink -v build/root.fs/etc/resolv.conf > build/root.fs/etc/resolv.conf.bak
	rm -f build/root.fs/etc/resolv.conf
	echo "nameserver 185.121.177.177" > build/root.fs/etc/resolv.conf
	echo "axiom-$(DEVICE)" > build/root.fs/etc/hostname
	chroot build/root.fs /opt/axiom-firmware/makefiles/in_chroot/update.sh nopull
	ln -sf $$(cat build/root.fs/etc/resolv.conf.bak) build/root.fs/etc/resolv.conf

	$(MAKE) -f makefiles/host/main.mk umount
	touch $@


.PHONY: mount
mount: umount build/root.fs
	mount --rbind build/root.fs/ build/root.fs/
	mount -t proc /proc build/root.fs/proc
	mount -o bind /dev build/root.fs/dev
	mount -o bind /dev/pts build/root.fs/dev/pts
	mount -o bind /sys build/root.fs/sys

.PHONY: umount
umount:
	-umount build/root.fs/sys
	-umount build/root.fs/dev/pts
	-umount build/root.fs/dev/
	-umount build/root.fs/proc
	-umount build/root.fs/



build/root.fs/opt/axiom-firmware: $(shell find -type f -not -path "./build/*") build/root.fs
	mkdir -p build/root.fs/opt/axiom-firmware
	rsync -a . --exclude=build build/root.fs/opt/axiom-firmware


build/root.fs: build/ArchLinuxARM-zedboard-latest.tar.gz
	mkdir -p build/root.fs
	tar --warning=no-unknown-keyword -x -C build/root.fs -f build/ArchLinuxARM-zedboard-latest.tar.gz


build/ArchLinuxARM-zedboard-latest.tar.gz:
	mkdir -p build
	(cd build; wget -c -nv http://archlinuxarm.org/os/ArchLinuxARM-zedboard-latest.tar.gz)

include bootfs.mk

LINUX_BASE_IMAGE=ArchLinuxARM-zedboard-latest.tar.gz

build/root.fs/.install_stamp: $(shell find makefiles/in_chroot/) build/root.fs/opt/axiom-firmware $(LINUX_SOURCE)/arch/arm/boot/zImage build/root.fs/.base_install
	rsync -aK build/kernel_modules.fs/ build/root.fs/
	echo "$(DEVICE)" > build/root.fs/etc/hostname
	+./makefiles/host/run_in_chroot.sh /opt/axiom-firmware/makefiles/in_chroot/install.sh 

	cp build/build.log build/root.fs/var/
	touch $@

build/root.fs/opt/axiom-firmware: $(shell find -type f -not -path "./build/*")
	mkdir -p build/root.fs/opt/axiom-firmware
	rsync -a . --exclude=build build/root.fs/opt/axiom-firmware

	touch $@

build/root.fs/.base_install: build/$(LINUX_BASE_IMAGE)
	mkdir -p build/root.fs
	tar --warning=no-unknown-keyword -x -C build/root.fs -f build/$(LINUX_BASE_IMAGE)

	touch $@


build/$(LINUX_BASE_IMAGE):
	@mkdir -p $(@D)
	(cd build && wget -c -nv http://archlinuxarm.org/os/$(LINUX_BASE_IMAGE))

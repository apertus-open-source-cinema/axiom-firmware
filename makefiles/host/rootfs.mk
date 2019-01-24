include bootfs.mk

LINUX_BASE_IMAGE=void-armv7l-ROOTFS.tar.xz

build/root.fs/.install_stamp: $(shell find makefiles/in_chroot/) build/root.fs/opt/axiom-firmware/.install_stamp $(LINUX_SOURCE)/arch/arm/boot/zImage build/root.fs/.base_install
	rsync -aK build/kernel_modules.fs/ $(@D)
	echo "$(DEVICE)" > $(@D)/etc/hostname
	+./makefiles/host/run_in_chroot.sh /opt/axiom-firmware/makefiles/in_chroot/install.sh 

	cp build/build.log $(@D)/var/
	touch $@

build/root.fs/opt/axiom-firmware/.install_stamp: $(shell find -type f -not -path "./build/*")
	mkdir -p $(@D)
	rsync -a . --exclude=build $(@D)

	touch $@

build/root.fs/.base_install: build/$(LINUX_BASE_IMAGE)
	mkdir -p $(@D)
	tar -xJ -C $(@D) -f $<

	touch $@


build/$(LINUX_BASE_IMAGE):
	mkdir -p $(@D)
	wget -q -O $@ "https://alpha.de.repo.voidlinux.org/live/current/$$(wget -q -O - https://alpha.de.repo.voidlinux.org/live/current/ | grep -o 'void-armv7l-ROOTFS[^"]*\.tar\.xz' | head -n1)"

include bootfs.mk

LINUX_BASE_IMAGE=ArchLinuxARM-zedboard-latest.tar.gz

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
	tar --warning=no-unknown-keyword -x -C $(@D) -f $<

	touch $@


build/$(LINUX_BASE_IMAGE):
	mkdir -p $(@D)
	wget -c -nv http://archlinuxarm.org/os/$(LINUX_BASE_IMAGE) -O $@

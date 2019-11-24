include bootfs.mk

LINUX_BASE_IMAGE=ArchLinuxARM-zedboard-latest.tar.gz

build/root.fs/.install_stamp: $(shell find makefiles/in_chroot/) build/root.fs/opt/axiom-firmware/.install_stamp $(LINUX_SOURCE)/arch/arm/boot/zImage build/root.fs/.base_install build/webui/dist/index.html build/nctrl/target/release/nctrl
	rsync -aK build/kernel_modules.fs/ $(@D)

	cp -r build/webui/dist $(@D)/opt/axiom-firmware/software/webui

	mkdir -p $(@D)/usr/axiom/bin
	cp build/nctrl/target/armv7-unknown-linux-musleabihf/release/nctrl $(@D)/usr/axiom/bin/nctrl

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
	# use a fixed mirror because some are verry unstable :(
	wget --no-verbose -c -nv http://de3.mirror.archlinuxarm.org/os/$(LINUX_BASE_IMAGE) -O $@


build/webui/.copy_stamp: $(shell find -type f software/webui/")
	cp -r software/webui build/
	touch $@

build/webui/dist/index.html: build/webui/.copy_stamp
	cd build/webui; yarnpkg install --no-progress; yarnpkg build


build/nctrl/.copy_stamp: $(shell find -type f software/nctrl/")
	cp -r software/nctrl build/
	mkdir -p build/nctrl/.cargo
	echo -e "[target.armv7-unknown-linux-musleabihf]\n linker = \"arm-buildroot-linux-musleabihf-gcc\"" > build/nctrl/.cargo/config
	touch $@

build/nctrl/target/release/nctrl: build/nctrl/.copy_stamp
	cd build/nctrl && \
	CROSS_COMPILE=arm-buildroot-linux-musleabihf- \
	CFLAGS="-mfpu=neon" \
	FUSE_CROSS_STATIC_PATH=./thirdparty/ \
	FUSE_CROSS_STATIC_LIB=fuse \
	cargo build --release --target=armv7-unknown-linux-musleabihf

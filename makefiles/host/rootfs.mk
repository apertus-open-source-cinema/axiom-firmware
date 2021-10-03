include bootfs.mk

LINUX_BASE_IMAGE=ArchLinuxARM-zedboard-latest.tar.gz

OPENOCD_VERSION = d46f28c2ea2611f5fbbc679a5eed253d3dcd2fe3
OPENOCD_SOURCE = build/openocd-$(OPENOCD_VERSION).git

build/root.fs/.install_stamp: $(shell find makefiles/in_chroot/) build/root.fs/opt/axiom-firmware/.install_stamp $(LINUX_SOURCE)/arch/arm/boot/zImage build/root.fs/.base_install build/webui/dist/index.html build/nctrl/target/armv7-unknown-linux-musleabihf/release/nctrl $(OPENOCD_SOURCE)/.build_stamp
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


build/webui/.copy_stamp: $(shell find software/webui/ -type f)
	cp -r software/webui build/
	touch $@

build/webui/dist/index.html: build/webui/.copy_stamp
	cd build/webui; yarnpkg install --no-progress; yarnpkg build


build/nctrl/.copy_stamp: $(shell find software/nctrl/ -type f)
	cp -r software/nctrl build/
	mkdir -p build/nctrl/.cargo
	echo -e "[target.armv7-unknown-linux-musleabihf]\n linker = \"arm-buildroot-linux-musleabihf-gcc\"" > build/nctrl/.cargo/config
	touch $@

build/nctrl/target/armv7-unknown-linux-musleabihf/release/nctrl: build/nctrl/.copy_stamp
	cd build/nctrl && \
	CROSS_COMPILE=arm-buildroot-linux-musleabihf- \
	CFLAGS="-mfpu=neon" \
	FUSE_CROSS_STATIC_PATH=./thirdparty/ \
	FUSE_CROSS_STATIC_LIB=fuse \
	cargo build --release --target=armv7-unknown-linux-musleabihf

OPENOCD_PATCHES = $(wildcard patches/openocd/*.patch)
$(OPENOCD_SOURCE)/.source: build/root.fs/.base_install $(OPENOCD_PATCHES)
	@mkdir -p $(@D)
	rm -rf $(@D)
	git clone https://repo.or.cz/openocd.git $(@D)
	(cd $(@D) && git reset --hard $(OPENOCD_VERSION))
	./makefiles/host/patch_wrapper.sh $(@D) $(OPENOCD_PATCHES)
	touch $(@D)/.scmversion
	touch $@

$(OPENOCD_SOURCE)/.build_stamp: $(OPENOCD_SOURCE)/.source build/root.fs/.base_install
	(cd $(@D) && ./bootstrap)
	(cd $(@D) && PKG_CONFIG=/root/armv7-eabihf--musl--bleeding-edge-2020.02-2/bin/pkg-config ./configure --host=arm-buildroot-linux-musleabihf --enable-static --enable-rfdev-jtag --enable-sysfsgpio --prefix=$${PWD}/../root.fs/usr/ CFLAGS="--static")
	+(cd $(@D) &&  $(MAKE))
	+(cd $(@D) &&  $(MAKE) install)
	touch $@

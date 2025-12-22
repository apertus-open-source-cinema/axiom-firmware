# SPDX-FileCopyrightText: © 2019 Robin Ole Heinemann <robin.ole.heinemann@gmail.com>
# SPDX-License-Identifier: CC-BY-SA-4.0

FROM ubuntu:rolling
ARG DEBIAN_FRONTEND=noninteractive
RUN echo "Europe/Berlin" > /etc/timezone
RUN apt-get update -q
RUN apt-get install tzdata
RUN dpkg-reconfigure -f noninteractive tzdata
RUN apt-get install -y -q \
	curl \
	wget \ 
	git \ 
	e2fsprogs  \ 
	mtools \ 
	build-essential \ 
	gcc-arm-linux-gnueabi \ 
	libglib2.0-dev \ 
	zlib1g-dev \ 
	dh-autoreconf \ 
	flex \ 
	bison \ 
	dosfstools \ 
	bc \ 
	boxes \ 
	python-is-python3 \ 
	qemu-system \
	qemu-user-static \ 
	binfmt-support \
	openssl \ 
	expect \ 
	libssl-dev \ 
	libelf-dev \ 
	device-tree-compiler \ 
	libpixman-1-dev \ 
	rsync \
	ncurses-dev \
	kmod \
	lz4 \
	gdb \
	btrfs-progs \
	gnupg \
	nodejs \
	npm \
	yarnpkg \
	fdisk
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && $HOME/.cargo/bin/rustup target add armv7-unknown-linux-musleabihf
RUN curl https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--musl--stable-2025.08-1.tar.xz | tar -xvJ -C /root
ENV PATH="${PATH}:/root/.cargo/bin/:/root/armv7-eabihf--musl--stable-2025.08-1/bin/"
COPY qemu-aarch64 /var/lib/binfmts
COPY qemu-arm /var/lib/binfmts

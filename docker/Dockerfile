FROM ubuntu:19.04
RUN echo "Europe/Berlin" > /etc/timezone
RUN apt-get update -q 
RUN apt-get install tzdata
RUN dpkg-reconfigure -f noninteractive tzdata
RUN apt-get install -y -q \
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
	python \ 
    qemu \
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
	liblz4-tool \
    gdb \
    btrfs-progs
COPY qemu-aarch64 /var/lib/binfmts
COPY qemu-arm /var/lib/binfmts

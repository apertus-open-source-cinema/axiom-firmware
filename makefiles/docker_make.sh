#!/bin/sh
# build the whole image inside a docker image, but with mounted files
cd $(dirname $(realpath $0))/../
set -e

# check for the right privileges
docker ps > /dev/null || echo "you either dont have docker installed or are missing the rights to exec it. \n try running again with sudo"

# do the real exec
docker run --privileged -v $(pwd):/root/axiom-firmware/ -w /root/axiom-firmware/ -it "jatha/axiom-build-container:latest" /bin/bash -c "make -f makefiles/host/main.mk -I makefiles/host -j -l $(nproc) $*"

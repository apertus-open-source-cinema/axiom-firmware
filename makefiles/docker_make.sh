#!/bin/sh
# build the whole image inside a docker image, but with mounted files
cd $(dirname $(realpath $0))/../
set -e

# check for the right privileges
docker ps > /dev/null

# do the real exec
docker run --privileged -v $(pwd):/root/axiom-firmware/ -w /root/axiom-firmware/ -it jatha/axiom-build-container:latest /bin/bash -c "make -f makefiles/host/main.mk -I makefiles/host -j -l $(nproc) $*"

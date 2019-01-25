#!/bin/bash
# build the whole image inside a docker image, but with mounted files
cd $(dirname $(realpath $0))/../
set -eo pipefail

# initialize submodules if nescessary
# TODO(robin): breaks updating submodules without commiting the update
# (git submodule status --recursive | grep "^-") && git submodule update --init --recursive

# check for the right privileges
docker ps > /dev/null

# do the real exec
mkdir -p build
echo -e "\n\n\nstarting build at $(date) for commit $(git describe --always --abbrev=8 --dirty)" >> build/build.log
docker run --privileged \
    -h "axiom-build" \
    -v /dev:/dev \
    -v $(pwd):/root/axiom-firmware/ \
    -w /root/axiom-firmware/ \
    -l axiom-build \
    $([ -z "$CI" ] && echo "-it" ) \
    vupvupvup/axiom_build:latest \
    /bin/bash -c "make -f makefiles/host/main.mk -I makefiles/host -j $(nproc) $*" \
| tee -a build/build.log

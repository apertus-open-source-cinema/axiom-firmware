#!/bin/bash
echo "starting the full build..."
set -e 
set -o pipefail
cd $(dirname $(realpath $0))/../

echo -e "\ninstalling requirements:\n"
apt-get update -qq
apt-get install -y -qq $(grep -vE "^\s*#" build_tools/outside/dependencies.txt | tr "\n" " ") > /dev/null


echo -e "\nbuilding the rootfs:\n"
build_tools/outside/build_rootfs.sh


echo -e "\nbuilding the kernel:\n"
build_tools/outside/build_kernel.sh


echo -e "\nbuilding u-boot:\n"
build_tools/outside/build_u_boot.sh


echo -e "\nassamblying the image:\n"
build_tools/outside/assemble_image.sh


echo "build finished :)"
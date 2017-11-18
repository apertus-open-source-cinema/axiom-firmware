#!/bin/bash
set -e 
set -o pipefail
cd /opt/beta-software


# make a sysupdate
pacman --noconfirm -Syu


# build all the tools
function cdmake () {
    [[ -d "$1" ]] && cd "$1" && make && make install
}
for dir in $(ls -d software/cmv_tools/*/); do (cdmake "$dir"); done
for dir in $(ls -d software/processing_tools/*/); do (cdmake "$dir"); done

for script in software/scripts/*.sh; do ln -sf $(pwd)/$script /usr/local/bin/axiom-$(basename $script); done
for script in software/scripts/*.py; do ln -sf $(pwd)/$script /usr/local/bin/axiom-$(basename $script); done

ln -sf $(pwd)/build_tools/inside/update.sh /usr/local/bin/axiom-update

# install Pure Python library for PNG image encoding/decoding 
pip install pypng

# TODO: build and install the control daemon

# TODO: build the misc tools from: https://github.com/apertus-open-source-cinema/misc-tools-utilities/tree/master/raw2dng


# Add login headers to users
figlet "AXIOM Beta" > /etc/motd
echo "Software version $(git rev-parse --short HEAD). Last updated on $(date +"%d.%m.%y %H:%M UTC")" >> /etc/motd
echo "To update run, \"axiom-update\"." >> /etc/motd


# finish the update
echo "axiom-update finished. Software version is now $(git rev-parse --short HEAD)."
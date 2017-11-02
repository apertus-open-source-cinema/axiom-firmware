#!/bin/bash
set -e 
set -o pipefail
cd /opt/beta-software


# make a sysupdate
pacman --noconfirm -Syu


# build all the tools
for dir in $(find software/cmv_tools/ -maxdepth 1 -type d | tail -n +2); do (cd $dir && make && make install); done
for dir in $(find software/processing_tools/ -maxdepth 1 -type d | tail -n +2); do (cd $dir && make && make install); done

for script in software/scripts/*.sh; do ln -sf $(pwd)/$script /usr/local/bin/axiom-$(basename $script .sh); done
for script in software/scripts/*.py; do ln -sf $(pwd)/$script /usr/local/bin/axiom-$(basename $script .py); done

ln -sf $(pwd)/build_tools/inside/update.sh /usr/local/bin/axiom-update

# TODO: build and install the control daemon

# TODO: build the misc tools from: https://github.com/apertus-open-source-cinema/misc-tools-utilities/tree/master/raw2dng


# Add login headers to users
figlet "Axiom-Beta" > /etc/motd
echo "Software version $(git rev-parse --short HEAD). Last updated on $(date +"%d.%m.%y %H:%M UTC")" >> /etc/motd
echo "To update run, \"axiom-update\"." >> /etc/motd


# finish the update
echo "axiom-update finished. Software version is now $(git rev-parse --short HEAD)."
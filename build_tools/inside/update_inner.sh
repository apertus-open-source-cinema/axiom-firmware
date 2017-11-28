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

# configure lighttpd
cp -f software/configs/lighttpd.conf /etc/lighttpd/lighttpd.conf
systemctl enable lighttpd

# build and install the control daemon
(cd software/control_daemon/; mkdir build)
(cd software/control_daemon/build/; cmake ..)
(cd software/control_daemon/build/; make -j$(nproc))
(cd software/control_daemon/build/; ./install_daemon.sh)
cp -rf software/control_daemon/TestGUI/* /srv/http/

# download prebuid fpga binaries & select the default binary
# TODO: build them with vivado in ci
mkdir -p /opt/bitstreams
(cd /opt/bitstreams; curl http://vserver.13thfloor.at/Stuff/AXIOM/BETA/cmv_hdmi3_dual_60.bit > cmv_hdmi3_dual_60.bit)
(cd /opt/bitstreams; curl http://vserver.13thfloor.at/Stuff/AXIOM/BETA/cmv_hdmi3_dual_30.bit > cmv_hdmi3_dual_30.bit)
(cd /opt/bitstreams; ln -s $(pdw)/cmv_hdmi3_dual_30.bit soc_main.bit)


# TODO: build the misc tools from: https://github.com/apertus-open-source-cinema/misc-tools-utilities/tree/master/raw2dng


# Add login headers to users
figlet "AXIOM Beta" > /etc/motd
echo "Software version $(git rev-parse --short HEAD). Last updated on $(date +"%d.%m.%y %H:%M UTC")" >> /etc/motd
echo "To update run, \"axiom-update\"." >> /etc/motd


# finish the update
echo "axiom-update finished. Software version is now $(git rev-parse --short HEAD)."
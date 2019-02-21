#!/bin/bash
set -xeuo pipefail
DEVICE=$(cat /etc/hostname)

cd /opt/axiom-firmware


# configure pacman & do sysupdate
sed -i 's/^CheckSpace/#CheckSpace/g' /etc/pacman.conf
sed -i 's/#IgnorePkg   =/IgnorePkg = linux linux-*/' /etc/pacman.conf
pacman-key --init
pacman-key --populate archlinuxarm
pacman --noconfirm --needed -Syu
pacman --noconfirm -R linux-zedboard || true

# install dependencies
# pacman -R pkgconf --noconfirm || true
pacman --noconfirm --needed -S $(grep -vE "^\s*#" makefiles/in_chroot/requirements_pacman.txt | tr "\n" " ")

# evil hack because archlinux-arm has fucked up packages
cat /etc/ca-certificates/extracted/cadir/* > /etc/ca-certificates/extracted/tls-ca-bundle.pem

pip install -r makefiles/in_chroot/requirements_pip.txt

# setup users
if ! grep "dont log in as root" /root/.profile; then
    echo 'echo -e "\033[31;5municorns dont log in as root\033[0m"' >> /root/.profile
fi

PASS=axiom
USERNAME=operator
if ! [ -d /home/$USERNAME ]; then
    useradd -p $(openssl passwd -1 $PASS) -d /home/"$USERNAME" -m -g users -s /bin/bash "$USERNAME"
    echo "$USERNAME      ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    rm -f /home/$USERNAME/.bashrc
fi

# remove default arch linux arm user
userdel -r -f alarm || true

# configure ssh
grep -x 'XPermitRootLogin no' build/root.fs/etc/ssh/sshd_config || echo "PermitRootLogin no" >> /etc/ssh/sshd_config
grep -x 'X11Forwarding yes' build/root.fs/etc/ssh/sshd_config || echo "X11Forwarding yes" >> /etc/ssh/sshd_config

# build all the tools
function cdmake () {
    [[ -d "$1" ]] && make -C "$1" && make -C "$1" install
}

mkdir -p /usr/axiom/bin/
echo 'PATH=${PATH}:/usr/axiom/bin' >> /etc/environment
for dir in $(ls -d software/sensor_tools/*/); do cdmake "$dir"; done
for dir in $(ls -d software/processing_tools/*/); do cdmake "$dir"; done

mkdir -p /usr/axiom/script/
echo 'PATH=$PATH:/usr/axiom/script' >> /etc/profile
for script in software/scripts/*.sh; do ln -sf $(pwd)/$script /usr/axiom/script/axiom-$(basename $script | sed "s/_/-/g"); done
for script in software/scripts/*.py; do ln -sf $(pwd)/$script /usr/axiom/script/axiom-$(basename $script | sed "s/_/-/g"); done

echo '#!/bin/bash' >> /usr/axiom/script/gen_etc_issue.sh
echo 'echo "apertus\e{lightred}°\e{reset} axiom $DEVICE running Arch Linux ARM [\m]" > /etc/issue' >> /usr/axiom/script/gen_etc_issue.sh
echo 'echo "Kernel \r" >> /etc/issue' >> /usr/axiom/script/gen_etc_issue.sh
echo 'echo "Build $(cd /opt/axiom-firmware; git describe --always --abbrev=8 --dirty)" >> /etc/issue' >> /usr/axiom/script/gen_etc_issue.sh
echo 'echo "Network (ipv4) \4 [$(cat /sys/class/net/eth0/address)]" >> /etc/issue' >> /usr/axiom/script/gen_etc_issue.sh
echo 'echo "Serial console on \l [\b baud]" >> /etc/issue' >> /usr/axiom/script/gen_etc_issue.sh
echo 'echo "initial login is \e{lightgreen}operator\e{reset} with password \e{lightgreen}axiom\e{reset}." >> /etc/issue' >> /usr/axiom/script/gen_etc_issue.sh
chmod a+x /usr/axiom/script/gen_etc_issue.sh

# build and install the control daemon
(cd software/axiom-control-daemon/
    [ -d build ] || mkdir -p build
    cd build
    cmake -G Ninja ..
    ninja
    ./install_daemon.sh
)

# configure lighttpd
cp -f software/configs/lighttpd.conf /etc/lighttpd/lighttpd.conf
systemctl enable lighttpd
cp -rf software/http/AXIOM-WebRemote/* /srv/http/

# TODO: build the misc tools from: https://github.com/apertus-open-source-cinema/misc-tools-utilities/tree/master/raw2dng
cdmake software/misc-tools-utilities/raw2dng

# download prebuilt fpga binaries & select the default binary
# also convert the bitstreams to the format expected by the linux kernel 
mkdir -p /opt/bitstreams/
BITSTREAMS="BETA/cmv_hdmi3_dual_60.bit BETA/cmv_hdmi3_dual_30.bit BETA/ICSP/icsp.bit check_pin10.bit check_pin20.bit"
for bit in $BITSTREAMS; do
    NAME=$(basename $bit)
    (cd /opt/bitstreams && wget http://vserver.13thfloor.at/Stuff/AXIOM/$bit -O $NAME)
    ./makefiles/in_chroot/to_raw_bitstream.py -f /opt/bitstreams/$NAME /opt/bitstreams/"$(basename ${NAME%.bit}).bin"
    ln -sf /opt/bitstreams/"${NAME%.bit}.bin" /lib/firmware
done
ln -sf /opt/bitstreams/cmv_hdmi3_dual_60.bin /lib/firmware/axiom-fpga-main.bin

cp software/scripts/axiom-start.service /etc/systemd/system/
if [[ $DEVICE == 'micro' ]]; then
    systemctl disable axiom
else
    # TODO(robin): disable for now, as it hangs the camera	
    # systemctl enable axiom-start
    true
fi

echo "i2c-dev" > /etc/modules-load.d/i2c-dev.conf
echo "ledtrig-heartbeat" > /etc/modules-load.d/ledtrig.conf

# configure bash
cp software/configs/bashrc /etc/bash.bashrc

# install overlay, if any is found
if [ -d overlay ]; then
    rsync -aK --exclude install.sh overlay/ /
    if [ -f overlay/install.sh ]; then
        bash overlay/install.sh
    fi
fi

# install /etc/issue generating service
cp software/configs/gen_etc_issue.service /etc/systemd/system/
systemctl enable /etc/systemd/system/gen_etc_issue.service

# generate the motd and indicate software version
echo -e "\033[38;5;15m$(tput bold)$(figlet "AXIOM ${DEVICE^}")  $(tput sgr0)" > /etc/motd
echo "Software version $(git describe --always --abbrev=8 --dirty). Last updated on $(date +"%d.%m.%y %H:%M UTC")" >> /etc/motd
echo "To update, run \"axiom-update\"." >> /etc/motd
echo "" >> /etc/motd
echo "$(tput setaf 1)$(cat DISCLAIMER.txt)$(tput sgr0)" >> /etc/motd
echo "" >> /etc/motd

echo "PARTUUID=f37043ff-02 /     ext4 defaults,rw 0 0"  > /etc/fstab
echo "PARTUUID=f37043ff-01 /boot vfat defaults,rw 0 0" >> /etc/fstab

# Generate file list for integrity check
VERIFY_DIRECTORIES="/etc /usr /opt"
HASH_LOCATION="/opt/integrity_check"
mkdir -p $HASH_LOCATION
# delete hashes so they aren't included in the new files list
rm -f $HASH_LOCATION/hashes.txt; rm -f $HASH_LOCATION/files.txt
find $VERIFY_DIRECTORIES -type f > $HASH_LOCATION/files.txt
# also hash file list
echo "$HASH_LOCATION/files.txt" >> $HASH_LOCATION/files.txt
hashdeep -c sha256 -f $HASH_LOCATION/files.txt > $HASH_LOCATION/hashes.txt

echo "axiom-update finished. Software version is now $(git describe --always --abbrev=8 --dirty)."

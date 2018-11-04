#!/bin/bash
set -e 
set -o pipefail
cd /opt/axiom-firmware


# first pull changes, if needed
if [[ ! $@ == *nopull* ]]; then
    git pull
    exec $0 nopull
    exit
else
    echo "to skip pulling code, use axiom-update nopull"
fi



# configure pacman & do sysupdate
sed -i 's/#IgnorePkg   =/IgnorePkg = linux linux-*/' /etc/pacman.conf
pacman-key --init
pacman-key --populate archlinuxarm
pacman --noconfirm --needed -Syu

# install dependencies
pacman -R pkgconf --noconfirm || true
pacman --noconfirm --needed -S $(grep -vE "^\s*#" makefiles/in_chroot/requirements_pacman.txt | tr "\n" " ")
pip install -r makefiles/in_chroot/requirements_pip.txt

# setup users
if ! grep "dont log in as root" /root/.profile; then
    echo 'echo -e "\033[31;5municorns dont log in as root\033[0m"' >> /root/.profile
fi

PASS=axiom
USERNAME=apertus
if ! [ -d /home/$USERNAME ]; then
    useradd -p $(openssl passwd -1 $PASS) -d /home/"$USERNAME" -m -g users -s /bin/bash "$USERNAME"
    echo "$USERNAME      ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

# configure ssh
grep -x 'XPermitRootLogin no' build/root.fs/etc/ssh/sshd_config || echo "PermitRootLogin no" >> /etc/ssh/sshd_config
grep -x 'X11Forwarding yes' build/root.fs/etc/ssh/sshd_config || echo "X11Forwarding yes" >> /etc/ssh/sshd_config
fi

# build all the tools
function cdmake () {
    [[ -d "$1" ]] && cd "$1" && make && make install
}
for dir in $(ls -d software/cmv_tools/*/); do (cdmake "$dir"); done
for dir in $(ls -d software/processing_tools/*/); do (cdmake "$dir"); done

for script in software/scripts/*.sh; do ln -sf $(pwd)/$script /usr/local/bin/axiom-$(basename $script); done
for script in software/scripts/*.py; do ln -sf $(pwd)/$script /usr/local/bin/axiom-$(basename $script); done

ln -sf $(pwd)/makefiles/in_chroot/update.sh /usr/local/bin/axiom-update

# configure lighttpd
cp -f software/configs/lighttpd.conf /etc/lighttpd/lighttpd.conf
systemctl enable lighttpd

# build and install the control daemon
(cd software/control_daemon/;
 if ! [ -d build ]; then
    mkdir -p build
    cd build
    cmake ..
 fi
)
(cd software/control_daemon/build/; make -j -l$(nproc))
(cd software/control_daemon/build/; ./install_daemon.sh)
cp -rf software/http/AXIOM-WebRemote/* /srv/http/

# TODO: build the misc tools from: https://github.com/apertus-open-source-cinema/misc-tools-utilities/tree/master/raw2dng


# download prebuilt fpga binaries & select the default binary
function condLoad {
    if test -e "$1"; then
        zflag="-z '$1'"
    else
        zflag=""
    fi
    curl -o "$1" $zflag "$2"
}

mkdir -p /opt/bitstreams
(cd /opt/bitstreams; condLoad cmv_hdmi3_dual_60.bit http://vserver.13thfloor.at/Stuff/AXIOM/BETA/cmv_hdmi3_dual_60.bit)
(cd /opt/bitstreams; condLoad cmv_hdmi3_dual_30.bit http://vserver.13thfloor.at/Stuff/AXIOM/BETA/cmv_hdmi3_dual_30.bit)
(cd /opt/bitstreams; ln -sf $(pwd)/cmv_hdmi3_dual_30.bit soc_main.bit)

cp software/scripts/axiom-kick.service /etc/systemd/system/
systemctl enable axiom-kick


# finish the update
echo "apertus° $(cat /etc/hostname) Booted!" > /etc/issue
echo "Login as apertus with password axiom." >> /etc/issue

figlet "AXIOM  $(cat /etc/hostname | sed 's/axiom-//')" > /etc/motd
echo "Software version $(git describe --always --abbrev=8 --dirty). Last updated on $(date +"%d.%m.%y %H:%M UTC")" >> /etc/motd
echo "To update, run \"axiom-update\"." >> /etc/motd


echo "axiom-update finished. Software version is now $(git describe --always --abbrev=8 --dirty)."

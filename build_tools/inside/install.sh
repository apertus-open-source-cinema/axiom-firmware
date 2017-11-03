#!/bin/bash
set -e 
set -o pipefail
cd /opt/beta-software

# network config
mv /etc/resolv.conf /etc/resolv.conf.bak
echo "nameserver 185.121.177.177" > /etc/resolv.conf

# configure pacman & do initial database sync
sed -i 's/#IgnorePkg   =/IgnorePkg = linux linux-*/' /etc/pacman.conf
pacman --noconfirm -Syu

# install dependencies
pacman --noconfirm -Syu
pacman --noconfirm -S $(grep -vE "^\s*#" build_tools/inside/dependencies.txt | tr "\n" " ")

# do the normal axiom-update procedure
build_tools/inside/update.sh

# setup hostname & set before login message
echo "axiom-beta" > /etc/hostname
echo "Apertus AXIOM Beta Booted!" > /etc/issue
echo "Login as apertus with password axiom." >> /etc/issue

# setup users
echo 'echo -e "\033[31;5municorns dont log in as root\033[0m"' >> /root/.profile

PASS=axiom
USERNAME=apertus
useradd -p $(openssl passwd -1 $PASS) -d /home/"$USERNAME" -m -g users -s /bin/bash "$USERNAME"
echo "$USERNAME      ALL=(ALL) ALL" >> /etc/sudoers

# configure ssh
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "X11Forwarding yes" >> /etc/ssh/sshd_config

# undo the temporary hacks
mv /etc/resolv.conf.bak /etc/resolv.conf
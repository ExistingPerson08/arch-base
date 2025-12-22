#!/bin/bash

set -ouex pipefail

# Necessary for general behavior expected by image-based systems
sed -i 's|^HOME=.*|HOME=/var/home|' "/etc/default/useradd" && \
rm -rf /boot /home /root /usr/local /srv /var /usr/lib/sysimage/log /usr/lib/sysimage/cache/pacman/pkg && \
mkdir -p /sysroot /boot /usr/lib/ostree /var && \
ln -s sysroot/ostree /ostree && ln -s var/roothome /root && ln -s var/srv /srv && ln -s var/opt /opt && ln -s var/mnt /mnt && ln -s var/home /home && \
echo "$(for dir in opt home srv mnt usrlocal ; do echo "d /var/$dir 0755 root root -" ; done)" | tee -a "/usr/lib/tmpfiles.d/bootc-base-dirs.conf" && \
printf "d /var/roothome 0700 root root -\nd /run/media 0755 root root -" | tee -a "/usr/lib/tmpfiles.d/bootc-base-dirs.conf" && \
printf '[composefs]\nenabled = yes\n[sysroot]\nreadonly = true\n' | tee "/usr/lib/ostree/prepare-root.conf"

# Setup a temporary root passwd (changeme) for dev purposes
# pacman -S whois --noconfirm
# usermod -p "$(echo "changeme" | mkpasswd -s)" root

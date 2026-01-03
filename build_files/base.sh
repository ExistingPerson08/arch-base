#!/bin/bash

set -ouex pipefail

pacman -Syu --noconfirm

# Move everything from `/var` to `/usr/lib/sysimage` so behavior around pacman remains the same on `bootc usroverlay`'d systems
grep "= */var" /etc/pacman.conf | sed "/= *\/var/s/.*=// ; s/ //" | xargs -n1 sh -c 'mkdir -p "/usr/lib/sysimage/$(dirname $(echo $1 | sed "s@/var/@@"))" && mv -v "$1" "/usr/lib/sysimage/$(echo "$1" | sed "s@/var/@@")"' '' && \
sed -i -e "/= *\/var/ s/^#//" -e "s@= */var@= /usr/lib/sysimage@g" -e "/DownloadUser/d" /etc/pacman.conf

pacman -Sy --noconfirm base dracut linux linux-firmware ostree btrfs-progs e2fsprogs xfsprogs dosfstools skopeo dbus dbus-glib glib2 ostree shadow && pacman -S --clean --noconfirm

# Enable chaotic-aur
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --init && pacman-key --lsign-key 3056513887B78AEB
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
echo -e '[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' >> /etc/pacman.conf

# Enable other repos
sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf # multilib
pacman -Syy

# Install bootc
pacman -S bootc --noconfirm

# Useful utilities
pacman -S --noconfirm reflector sudo bash fastfetch nano openssh unzip tar flatpak fuse2 fzf just wl-clipboard
pacman -S --noconfirm libmtp nss-mdns samba smbclient networkmanager udiskie udisks2 udisks2-btrfs lvm2 cups cups-browsed hplip wireguard-tools
pacman -S --noconfirm distrobox podman squashfs-tools zstd

# Codecs and media
pacman -S --noconfirm ffmpeg ffmpegthumbnailer libcamera libcamera-tools libheif

# Drivers
pacman -S --noconfirm amd-ucode intel-ucode efibootmgr shim mesa libva-intel-driver libva-mesa-driver \
    vpl-gpu-rt vulkan-icd-loader vulkan-intel vulkan-radeon apparmor xf86-video-amdgpu zram-generator \
    lm_sensors intel-media-driver

# Systemd services
systemctl enable polkit.service \
    NetworkManager.service \
    cups.socket \
    cups-browsed.service

# Cleanup
rm -rf \
    /tmp/* \
    /var/cache/pacman/pkg/*

# Initramfs
printf "systemdsystemconfdir=/etc/systemd/system\nsystemdsystemunitdir=/usr/lib/systemd/system\n" | tee /usr/lib/dracut/dracut.conf.d/30-bootcrew-fix-bootc-module.conf
printf 'reproducible=yes\nhostonly=no\ncompress=zstd\nadd_dracutmodules+=" ostree bootc "' | tee "/usr/lib/dracut/dracut.conf.d/30-bootcrew-bootc-container-build.conf"
dracut --force "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)/initramfs.img"

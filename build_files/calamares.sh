#!/bin/bash

set -ouex pipefail

# Add live environment
pacman -Sy --noconfirm --needed \
    base-devel git \
    networkmanager \
    cosmic cosmic-session cosmic-greeter

# Virtio drivers
pacman -S --noconfirm xf86-video-fbdev xf86-video-vesa qemu-hw-display-virtio-gpu vulkan-virtio

# Install calamares from AUR
pacman -Sy --noconfirm --needed base-devel git \
    kcoreaddons qt6-declarative libpwquality yaml-cpp kpmcore qt6-svg \
    extra-cmake-modules ninja qt6-tools qt6-translations

useradd -m builduser
echo "builduser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builduser

sudo -u builduser bash << 'EOF'
    cd /tmp
    git clone https://aur.archlinux.org/calamares.git
    cd calamares
    # --noconfirm přeskočí dotazy, --syncdeps nainstaluje chybějící deps
    makepkg -si --noconfirm
EOF

useradd -m -G wheel,video,audio,render,tty -s /bin/bash live
echo "live:live" | chpasswd

# No password for sudo in live session
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/live

# Autostart calamares
mkdir -p /home/live/.config/autostart
cat <<EOF > /home/live/.config/autostart/calamares.desktop
[Desktop Entry]
Type=Application
Name=Install System
Exec=sudo calamares
Icon=system-installer
Terminal=false
EOF
chown -R live:live /home/live/.config

systemctl enable cosmic-greeter
systemctl enable NetworkManager

# Cleanup
rm /etc/sudoers.d/builduser
userdel -r builduser

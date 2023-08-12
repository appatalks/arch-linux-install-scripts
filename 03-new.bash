#!/bin/bash

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

#
pacman -S git --noconfirm
git clone https://github.com/FreedomBen/arch-linux-install-scripts.git


# Create non-root user with wheel group access and passwordless sudo
useradd -m -G wheel -s /bin/bash username
passwd -d username
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

# Install GNOME and display manager (GDM)
pacman -S --noconfirm gnome gnome-extra gdm

# Enable GDM
systemctl enable gdm

# Set up DHCP networking
systemctl enable systemd-networkd
systemctl enable systemd-resolved
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Set timezone to CDT
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc

# Install required packages and dependencies
pacman -S --noconfirm vim iptables htop lsof iftop openssh screen terminator dnsutils linux-headers python-pip python base-devel

# Ask user for additional common packages
read -p "Would you like to install additional common packages? (y/n): " package_choice
if [ "$package_choice" = "y" ]; then
    # Install additional common packages based on user's choice
    pacman -S --noconfirm firefox chromium wireguard-tools package4 package5
fi

EOF

echo "Installation and configuration completed!"


#!/bin/bash

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

#
pacman -S git --noconfirm
git clone https://github.com/FreedomBen/arch-linux-install-scripts.git
cd arch-linux-install-scripts/

# Set the hostname
echo "archer" > /etc/hostname

# Add hostname to /etc/hosts
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 archer.localdomain archer" >> /etc/hosts

# usually not required
mkinitcpio -P

# Set the root password
echo "root:password" | chpasswd

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
pacman -S --noconfirm --needed vim iptables htop lsof iftop openssh screen terminator dnsutils linux-headers python-pip python base-devel unrar nmap bc p7zip bash-completion tmux lsb-release pkgfile lm_sensors rsync
pkgfile --update
yes "" | sensors-detect

# Ask user for additional common packages
read -p "Would you like to install additional common packages? (y/n): " package_choice
if [ "$package_choice" = "y" ]; then
    # Install additional common packages based on user's choice
    pacman -S --noconfirm firefox chromium wireguard-tools vlc gnome-tweak-tool recordmydesktop imagemagick transmission-gtk xchat gimp 
fi

    if [ "$LIBREOFFICE" = "y" -o "$LIBREOFFICE" = "Y" ]; then
        pacman -S --noconfirm --needed libreoffice-base libreoffice-calc libreoffice-common \
        libreoffice-draw libreoffice-en-US libreoffice-gnome libreoffice-impress libreoffice-math \
        libreoffice-writer
    fi

# Install VirtualBox Guest Modules if in a VBox VM
if [ "$GUESTVM" = "y" -o "$GUESTVM" = "Y" ]; then
    pacman -S --noconfirm --needed virtualbox-guest-modules virtualbox-guest-utils

    VBOX_CONF="/etc/modules-load.d/virtualbox.conf"

    echo "vboxguest" > "$VBOX_CONF"
    echo "vboxsf" >> "$VBOX_CONF"
    echo "vboxvideo" >> "$VBOX_CONF"
fi

# Install VirtualBox
if [ "$VBOX" = "Y" -o "$VBOX" = "y" ]; then
    VBOX_CONF="/etc/modules-load.d/virtualbox.conf"

    if [ "$LINUXCK" = "y" -o "$LINUXCK" = "Y" ]; then
        pacman -S --noconfirm --needed dkms virtualbox-host-dkms virtualbox-guest-dkms
        aurinstall virtualbox-ck-host-modules
    fi

    pacman -S --noconfirm --needed virtualbox virtualbox-host-modules qt4
    pacman -S --noconfirm --needed net-tools
    pacman -S --noconfirm --needed virtualbox-guest-iso

    echo "vboxdrv" > "$VBOX_CONF"
    echo "vboxnetadp" >> "$VBOX_CONF"
    echo "vboxnetflt" >> "$VBOX_CONF"
    echo "vboxpci" >> "$VBOX_CONF"

    groupadd vboxusers
    [ -n "$USERNAME" ] && usermod -a -G vboxusers $USERNAME
fi

echo "Installation and configuration completed!"

read -p "Installation and configuration completed. Would you like to reboot now? (y/n): " reboot_choice
if [ "$reboot_choice" = "y" ]; then
    reboot
else
    echo "You can manually reboot the system when you're ready."
fi

#!/bin/bash

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Verify disk before proceeding
read -p "This script will erase all data on /dev/sda. Are you sure you want to continue? (y/n): " choice
if [ "$choice" != "y" ]; then
  echo "Script aborted."
  exit 1
fi

# Partitioning
echo "Partitioning /dev/sda..."
(
echo g       # Create a new GPT partition table
echo n       # New partition
echo 1       # Partition number 1
echo         # Default start sector
echo +512M   # 512MB EFI System Partition
echo t       # Change partition type
echo 1       # Select partition 1
echo 1       # Change to EFI type (Code 1)
echo n       # New partition
echo 2       # Partition number 2
echo         # Default start sector
echo         # Default end sector (use remaining space)
echo w       # Write changes
) | fdisk /dev/sda

# Formatting EFI partition
echo "Formatting EFI partition..."
mkfs.fat -F32 /dev/sda1

# Formatting root partition
echo "Formatting root partition..."
mkfs.ext4 /dev/sda2

# Mounting partitions
echo "Mounting partitions..."
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

echo "Disk preparation completed!"


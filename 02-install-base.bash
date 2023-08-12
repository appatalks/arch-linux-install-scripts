#!/bin/bash

# pacstrap the new system
pacstrap /mnt base

# Generate an fstab file (use -U or -L to define by UUID or labels, respectively):
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt


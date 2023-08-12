#/bin/bash

pacman -Sy
pacman-key --init

pacman -S git

git clone https://github.com/FreedomBen/arch-linux-install-scripts.git

cd arch-linux-install-scripts/

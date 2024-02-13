#!/bin/sh

set -e

./00_config.sh

sudo pacman --noconfirm -S ddcutil
sudo usermod -aG i2c $ARCH_INSTALL_USERNAME
sudo cat <<EOF >/etc/modules-load.d/i2c-dev.conf
i2c-dev
EOF

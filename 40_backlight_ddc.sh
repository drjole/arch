#!/bin/sh

set -e

sudo pacman --noconfirm -S ddcutil
sudo usermod -aG i2c $USER
cat <<EOF | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null
i2c-dev
EOF

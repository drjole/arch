#!/bin/sh

set -e

# Ask for the sudo password upfront and make sure it is not asked for again
sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

sudo pacman --noconfirm -S ddcutil
sudo usermod -aG i2c $USER
cat <<EOF | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null
i2c-dev
EOF

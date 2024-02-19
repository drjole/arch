#!/bin/bash

set -e

# Ask for the sudo password upfront and make sure it is not asked for again
sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

sudo pacman --noconfirm -S blueman bluez bluez-utils
sudo systemctl enable --now bluetooth.service

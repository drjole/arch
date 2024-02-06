#!/bin/sh

set -e

sudo pacman -S bluez bluez-utils blueman
sudo systemctl enable --now bluetooth.service

#!/bin/bash

set -e

sudo pacman --noconfirm -S blueman bluez bluez-utils
sudo systemctl enable --now bluetooth.service

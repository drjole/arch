#!/bin/bash

set -e

# Enable the multilib repository
sudo sed -i '/\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/s/^#//' /etc/pacman.conf

# Update the system
sudo pacman -Syu

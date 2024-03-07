#!/bin/bash

set -e

# Install steam and grapics card independent drivers
sudo pacman --noconfirm -S steam \
  vulkan-icd-loader lib32-vulkan-icd-loader \
  xdg-desktop-portal xdg-desktop-portal-gtk

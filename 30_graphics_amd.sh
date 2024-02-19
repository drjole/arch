#!/bin/sh

set -e

# Install the AMD drivers
sudo pacman --noconfirm -S mesa xf86-video-amdgpu

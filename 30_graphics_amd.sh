#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Install the AMD drivers
pacman --noconfirm -S mesa xf86-video-amdgpu

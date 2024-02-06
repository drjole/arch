#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Install the NVIDIA drivers
pacman -S mesa nvidia

# Remove the kms hook from the initramfs
sed -i '/^HOOKS=(/s/ kms//' /etc/mkinitcpio.conf

# Regenerate the initramfs
mkinitcpio -P

echo "Now reboot the system to load the NVIDIA drivers."

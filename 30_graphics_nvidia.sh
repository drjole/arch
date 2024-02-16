#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Install the NVIDIA drivers
pacman --noconfirm -S mesa nvidia nvidia-settings

# Remove the kms hook from the initramfs
sed -i '/^HOOKS=(/s/ kms//' /etc/mkinitcpio.conf

# Add the nvidia modules to the initramfs
sed -i '/^MODULES=(/s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

# Set the DRM kernel mode setting kernel parameter
sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/s/"$/ nvidia-drm.modeset=1"/' /etc/default/grub

# Regenerate the initramfs
mkinitcpio -P

echo "Now reboot the system to load the NVIDIA drivers."

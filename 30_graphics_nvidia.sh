#!/bin/bash

set -e

# Ask for the sudo password upfront and make sure it is not asked for again
sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# Install the NVIDIA drivers
sudo pacman --noconfirm -S mesa nvidia nvidia-settings

# Remove the kms hook from the initramfs
sudo sed -i '/^HOOKS=(/s/ kms//' /etc/mkinitcpio.conf

# Add the nvidia modules to the initramfs
sudo sed -i '/^MODULES=(/s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

# Set the DRM kernel mode setting kernel parameter
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/s/"$/ nvidia-drm.modeset=1"/' /etc/default/grub

# Regenerate the initramfs and the GRUB configuration
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "Now reboot the system to load the NVIDIA drivers."

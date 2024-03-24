#!/bin/bash

set -e

#
# Setup the NVIDIA driver
#

# Remove the kms hook from the initramfs
sudo sed -i '/^HOOKS=(/s/ kms//' /etc/mkinitcpio.conf

# Add the nvidia modules to the initramfs
sudo sed -i '/^MODULES=(/s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

# Set the DRM kernel mode setting kernel parameter
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/s/"$/ nvidia-drm.modeset=1"/' /etc/default/grub

# Regenerate the initramfs and the GRUB configuration
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg

#
# Backlight control using ddcutil
#
sudo usermod -aG i2c $USER
cat <<EOF | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null
i2c-dev
EOF

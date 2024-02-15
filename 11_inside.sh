#!/bin/bash

set -e

# Load the configuration from the root directory inside the new system
source /00_config.sh

# Configure the initial ramdisk
sed -i '/^HOOKS=(/s/block/block encrypt lvm2/' /etc/mkinitcpio.conf
sed -i '/^HOOKS=(/s/filesystems/filesystems resume/' /etc/mkinitcpio.conf

# Install some essential packages
# This will also rebuild the initial ramdisk
pacman --noconfirm -S base-devel grub efibootmgr lvm2 "$ARCH_INSTALL_MICROCODE" git neovim zsh networkmanager

# Install GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck

# Setup the GRUB_CMDLINE_LINUX_DEFAULT line in /etc/default/grub
ROOT_PARTITION_UUID=$(blkid -s UUID -o value "$ARCH_INSTALL_ROOT_PARTITION")
SWAP_PARTITION_UUID=$(blkid -s UUID -o value /dev/mapper/arch-swap)
KERNEL_PARAMS="quiet splash loglevel=3 vt.global_cursor_default=0 udev.log_level=3 sysrq_always_enabled=1"
KERNEL_PARAMS="$KERNEL_PARAMS root=/dev/mapper/arch-root"
KERNEL_PARAMS="$KERNEL_PARAMS cryptdevice=UUID=$ROOT_PARTITION_UUID:luks_lvm"
KERNEL_PARAMS="$KERNEL_PARAMS resume=UUID=$SWAP_PARTITION_UUID"
sed -i "s|GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\"|GRUB_CMDLINE_LINUX_DEFAULT=\"$KERNEL_PARAMS\"|" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Configure NTP
sed -i '/^#NTP=/s/^#//' /etc/systemd/timesyncd.conf
sed -i '/^#FallbackNTP=/s/^#//' /etc/systemd/timesyncd.conf
sed -i '/^NTP=/s/^NTP=.*$/NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org/' /etc/systemd/timesyncd.conf
sed -i '/^FallbackNTP=/s/^FallbackNTP=.*$/FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org/' /etc/systemd/timesyncd.conf
systemctl enable systemd-timesyncd

# Setup locales
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf

# Set the hostname
echo "$ARCH_INSTALL_HOSTNAME" >/etc/hostname

# Set the root password
echo -e "$ARCH_INSTALL_ROOT_PASSWORD\n$ARCH_INSTALL_ROOT_PASSWORD" | passwd root

# Create a new user
useradd -m -G wheel -s /bin/zsh "$ARCH_INSTALL_USERNAME"
echo -e "$ARCH_INSTALL_USER_PASSWORD\n$ARCH_INSTALL_USER_PASSWORD" | passwd "$ARCH_INSTALL_USERNAME"

# Allow members of the wheel group to execute any command
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Enable NetworkManager
systemctl enable NetworkManager

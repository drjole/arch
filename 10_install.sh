#!/bin/sh

set -e

################################################################################################################
# This script assumes that the disks are already partitioned and that the system is connected to the internet. #
################################################################################################################

./00_config.sh

# Encrypt the root partition and open it after encryption
modprobe dm-crypt
modprobe dm-mod
echo -n "$ARCH_INSTALL_ROOT_PARTITION_PASSWORD" | cryptsetup luksFormat -v -s 512 -h sha512 "$ARCH_INSTALL_ROOT_PARTITION" -
echo -n "$ARCH_INSTALL_ROOT_PARTITION_PASSWORD" | cryptsetup open "$ARCH_INSTALL_ROOT_PARTITION" luks_lvm -

# Create the LVM physical volume, volume group and logical volumes
pvcreate /dev/mapper/luks_lvm
vgcreate arch /dev/mapper/luks_lvm
lvcreate -n swap -L "$ARCH_INSTALL_SWAP_SIZE" -C y arch
lvcreate -n root -l +100%FREE arch

# Format the logical volumes
mkfs.fat -F32 "$ARCH_INSTALL_BOOT_PARTITION"
mkfs.ext4 /dev/mapper/arch-root
mkswap /dev/mapper/arch-swap

# Enable swap
swapon /dev/mapper/arch-swap
swapon -a

# Mount the root and boot partitions
mount /dev/mapper/arch-root /mnt
mount --mkdir "$ARCH_INSTALL_BOOT_PARTITION" /mnt/boot

# Install the base system
pacstrap -K /mnt base linux linux-firmware

# Generate the fstab file
genfstab -U -p /mnt >/mnt/etc/fstab

# Chroot into the new system
arch-chroot /mnt /bin/bash

# Install some essential packages
pacman --noconfirm -S base-devel grub efibootmgr lvm2 "$ARCH_INSTALL_MICROCODE" git neovim zsh networkmanager

# Configure the initial ramdisk
sed -i '/^HOOKS=(/s/block/block encrypt lvm2/' /etc/mkinitcpio.conf
sed -i '/^HOOKS=(/s/filesystems/filesystems resume/' /etc/mkinitcpio.conf
mkinitcpio -P

# Install GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Setup the GRUB_CMDLINE_LINUX_DEFAULT line in /etc/default/grub
ROOT_PARTITION_UUID=$(blkid -s UUID -o value "$ARCH_INSTALL_ROOT_PARTITION")
SWAP_PARTITION_UUID=$(blkid -s UUID -o value /dev/mapper/arch-swap)
KERNEL_PARAMS="quiet splash loglevel=3 vt.global_cursor_default=0 udev.log_level=3 sysrq_always_enabled=1"
KERNEL_PARAMS="$KERNEL_PARAMS root=/dev/mapper/arch-root"
KERNEL_PARAMS="$KERNEL_PARAMS cryptdevice=UUID=$ROOT_PARTITION_UUID:luks_lvm"
KERNEL_PARAMS="$KERNEL_PARAMS resume=UUID=$SWAP_PARTITION_UUID"
sed -i "s|GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\"|GRUB_CMDLINE_LINUX_DEFAULT=\"$KERNEL_PARAMS\"|"
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
localectl set-locale LANG=en_US.UTF-8

# Set the hostname
echo "$ARCH_INSTALL_HOSTNAME" >/etc/hostname

# Set the root password
echo "$ARCH_INSTALL_ROOT_PASSWORD" | passwd --stdin root

# Create a new user
useradd -m -G wheel -s /bin/zsh "$ARCH_INSTALL_USERNAME"
echo "$ARCH_INSTALL_USER_PASSWORD" | passwd --stdin "$ARCH_INSTALL_USERNAME"

# Allow members of the wheel group to execute any command
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL' /etc/sudoers

# Enable NetworkManager
systemctl enable NetworkManager

# Unmount the partitions and reboot
exit
umount -R /mnt
reboot

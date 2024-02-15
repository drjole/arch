#!/bin/sh

set -e

################################################################################################################
# This script assumes that the disks are already partitioned and that the system is connected to the internet. #
################################################################################################################

source ./00_config.sh

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

# Chroot into the new system and continue from inside
cp ./11_inside.sh /mnt/11_inside.sh
cp ./00_config.sh /mnt/00_config.sh
arch-chroot /mnt /bin/bash /mnt/11_inside.sh
rm /mnt/11_inside.sh
rm /mnt/00_config.sh

# Unmount the partitions and reboot
umount -R /mnt
reboot

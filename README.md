# Installation Guide

## Obtain the Arch ISO

Download the Arch Linux ISO using the instructions from the [download page](https://archlinux.org/download/).
Also download `b2sums.txt`, `sha256sums.txt`, and the `*.sig` file containing a GPG signature of the image.

[Example download location](https://mirror.netcologne.de/archlinux/iso/latest/) by NetCologne.

## Verify the Integrity of the Arch ISO

```shell
b2sum -c b2sums.txt --ignore-missing
sha256sum -c sha256sums.txt --ignore-missing
gpg --auto-key-locate clear,wkd -v --locate-external-key pierre@archlinux.org
gpg --verify archlinux-x86_64.iso.sig
```

## Prepare the Installation MEDIUM

Define

```shell
INSTALLATION_MEDIUM=/dev/sdc
```

and run

```shell
sudo dd if=archlinux-x86_64.iso of="$INSTALLATION_MEDIUM" bs=4M status="progress"
```

Now boot the Arch ISO Live Environment using the installation medium.

## Connect to the Internet

Either plug in an Ethernet cable or connect to a WLAN using `iwctl` and by executing these commands in the interactive session:

```shell
device list
station wlan0 connect <SSID>
exit
```

## _Optional_: Enable SSH Access to the Live Environment

Enable the sshd service and set a password for the root user:

```shell
systemctl start sshd
passwd root
```

Connect to the machine using SSH from another machine. Use `ip addr` to get the IP address of the machine.

## Partition the Disks

Use `lsblk` to identify your disks.

After reading the [Arch Wiki page](https://wiki.archlinux.org/title/Partitioning), decide on a partition layout and apply it using `gdisk`.

These are my partition layouts:

### jolepc

#### `/dev/nvme0n1` (Root and Home Partition)

| Partition | First Sector | Last Sector | `gdisk` Code | Comment            |
| --------- | ------------ | ----------- | ------------ | ------------------ |
| 1         | default      | +512M       | EF00         | EFI (/boot)        |
| 2         | default      | default     | 8309         | / (LUKS encrypted) |

#### `/dev/sda` (General Purpose SDD)

| Partition | First Sector | Last Sector | `gdisk` Code | Comment        |
| --------- | ------------ | ----------- | ------------ | -------------- |
| 1         | default      | default     | 8300         | Arbitrary Data |

#### `/dev/sdb` (General Purpose HDD)

| Partition | First Sector | Last Sector | `gdisk` Code | Comment        |
| --------- | ------------ | ----------- | ------------ | -------------- |
| 1         | default      | default     | 8300         | Arbitrary Data |

### jolelaptop

#### `/dev/nvme0n1` (Root and Home Partition)

| Partition | First Sector | Last Sector | `gdisk` Code | Comment            |
| --------- | ------------ | ----------- | ------------ | ------------------ |
| 1         | default      | +512M       | EF00         | EFI (/boot)        |
| 2         | default      | default     | 8309         | / (LUKS encrypted) |

## Install the Base System

Adjust the values in `config.sh`.

Then run the install script:

```shell
./install.sh
```

After this script has finished executing, reboot:

```shell
reboot
```

Select the newly installed system in GRUB, log in using your defined credentials and download the dotfiles:

```shell
./dotfiles
```

Log out of the system:

```shell
exit
```

Now log back in and execute the post-install script:

```shell
./post-install.sh
```

Finally, run any of these scripts, as desired:

```shell
amd.sh
nvidia.sh
bluetooth.sh
backlight.sh
```

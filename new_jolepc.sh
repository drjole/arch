# In live ISO
sgdisk --zap-all /dev/nvme0n1
sgdisk --new=1:0:+512M --typecode=1:EF00 --change-name="0:EFI System Partition" /dev/nvme0n1
sgdisk --new=2:0:0 --typecode=2:8300 --change-name="1:Linux Filesystem" /dev/nvme0n1

mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2

mount /dev/nvme0n1p2 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot

pacstrap -K /mnt base linux linux-firmware

genfstab -U -p /mnt >/mnt/etc/fstab

arch-chroot /mnt /bin/bash

# Inside
pacman -S base-devel grub efibootmgr amd-ucode neovim git zsh networkmanager

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Enable en_US.UTF-8 locale in /etc/locale.gen
# Enable de_DE.UTF-8 locale in /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf

echo "jolepc" >/etc/hostname

passwd root
useradd -m -G wheel -s /bin/zsh jole
passwd jole

# Uncomment the wheel `wheel ALL=(ALL:ALL) ALL` line in /etc/sudoers

systemctl enable NetworkManager.service

exit

# In live ISO
umount -R /mnt
reboot

# In newly booted system
# In /etc/default/grub:
# 	Set GRUB_TIMEOUT=0
# 	Set GRUB_TIMEOUT_STYLE=hidden
# 	Run sudo grub-mkconfig -o /boot/grub/grub.cfg

# Set `ParallelDownloads = 5` in /etc/pacman.conf
# Set `MAKEFLAGS="-j$(nproc)" in /etc/makepkg.conf
# Uncomment the `[multilib]` section in /etc/pacman.conf

sudo pacman -S \
    mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon \
    qt5-wayland qt6-wayland \
    noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-font-awesome otf-font-awesome \
    hyprland uwsm libnewt xdg-desktop-portal-hyprland hyprpolkitagent hyprpaper rofi dunst hyprlock wl-clipboard hyprsunset grim slurp \
    waybar network-manager-applet \
    pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    alacritty firefox thunar spotify-launcher discord pavucontrol gimp inkscape libreoffice-still nextcloud-client signal-desktop vlc zathura zathura-pdf-poppler keepassxc steam teamspeak3 chromium gnome-keyring \
    qt5ct qt6ct kvantum breeze-icons \
    zsh-autosuggestions zsh-completions zsh-syntax-highlighting \
    fzf starship eza bat htop tmux ddcutil man-db ripgrep stow fd lazygit jq \
    blueman bluez bluez-utils \
    pacman-contrib \
    docker docker-compose docker-buildx mise pre-commit

systemctl --user enable --now hyprpaper.service
systemctl --user enable --now hyprpolkitagent.service
systemctl --user enable --now waybar.service

# Configure GNOME Keyring to automatically unlock on login
# NOTE: Set the same password for the keyring as for the login
#
# In /etc/pam.d/login:
# Add `auth       optional     pam_gnome_keyring.so` to the end of the auth section
# Add `session    optional     pam_gnome_keyring.so auto_start` to the end of the session section

# Rust
sudo pacman -S rustup
rustup default stable

# reditus
sudo pacman -S mkcert postgresql

git clone https://aur.archlinux.org/yay.git /tmp/yay
pushd /tmp/yay
makepkg -si
popd

sudo pacman -S papirus-icon-theme
yay -S catppuccin-cursors-mocha catppuccin-gtk-theme-mocha

git clone --recurse-submodules https://github.com/drjole/dotfiles ~/.dotfiles
pushd ~/.dotfiles
git remote set-url origin git@github.com:drjole/dotfiles.git
find . -mindepth 1 -maxdepth 1 -type d -not -name .git -printf "%f\n" | xargs -I {} mkdir -p "$HOME"/{}
stow .
popd

sudo systemctl enable --now paccache.timer

sudo usermod -aG i2c $USER
cat <<EOF | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null
i2c-dev
EOF

sudo systemctl enable --now bluetooth.service

mise trust ~/.dotfiles/.config/mise/config.toml
mise use -g usage node ruby

sudo systemctl enable --now docker.service
sudo usermod -a -G docker jole

# Make sensors work
echo nct6775 | sudo tee /etc/modules-load.d/nct6775.conf
echo "options nct6775 force_id=0xd802" | sudo tee /etc/modprobe.d/nct6775.conf

# Firefox
# Set `intl.regional_prefs.use_os_locales` to true to use german date formats in firefox while keeping language at english

sudo pacman -S lua-language-server
npm install -g @tailwindcss/language-server

#!/bin/bash

set -e

# Locales
if grep -q '^#.*en_US\.UTF-8' /etc/locale.gen; then
    sudo sed -i 's/^# *\(en_US\.UTF-8.*\)/\1/' /etc/locale.gen
    sudo locale-gen
fi
if grep -q '^#.*de_DE\.UTF-8' /etc/locale.gen; then
    sudo sed -i 's/^# *\(de_DE\.UTF-8.*\)/\1/' /etc/locale.gen
    sudo locale-gen
fi

# Configure pacman
# Enable multilib repository
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
fi
grep -q '^Color' /etc/pacman.conf || sudo sed -i '/^\[options\]/a Color' /etc/pacman.conf
grep -q '^ILoveCandy' /etc/pacman.conf || sudo sed -i '/^\[options\]/a ILoveCandy' /etc/pacman.conf

# Configure makepkg
if grep -q '^MAKEFLAGS=' /etc/makepkg.conf; then
    sudo sed -i "s/^MAKEFLAGS=.*/MAKEFLAGS=\"-j\$(nproc)\"/" /etc/makepkg.conf
else
    echo "MAKEFLAGS=\"-j\$(nproc)\"" | sudo tee -a /etc/makepkg.conf
fi

# Install all the packages
sudo pacman -Syu --noconfirm --needed \
    base-devel git \
    mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon \
    pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    hyprland uwsm libnewt xdg-desktop-portal-hyprland hyprpolkitagent hyprpaper waybar rofi dunst hyprlock wl-clipboard hyprsunset grim slurp qt5-wayland qt6-wayland \
    noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-font-awesome otf-font-awesome \
    alacritty firefox nautilus spotify-launcher discord pavucontrol gimp inkscape libreoffice-still nextcloud-client signal-desktop vlc zathura zathura-pdf-poppler steam teamspeak3 gnome-keyring \
    qt5ct qt6ct kvantum breeze-icons \
    zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting \
    neovim fzf starship eza bat htop tmux ddcutil man-db ripgrep fd lazygit jq \
    pacman-contrib

# yay
if ! command -v yay >/dev/null 2>&1; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    pushd /tmp/yay
    makepkg -si
    popd
fi

# Docker
sudo pacman -S --noconfirm --needed docker docker-compose docker-buildx
sudo systemctl enable --now docker.service
sudo usermod -a -G docker jole

# Configure PAM for GNOME Keyring unlocking
if ! grep -q '^auth \+optional \+pam_gnome_keyring.so' /etc/pam.d/login; then
    sudo sed -i '/^account/ i auth       optional     pam_gnome_keyring.so' /etc/pam.d/login
fi
if ! grep -q '^session \+optional \+pam_gnome_keyring.so auto_start' /etc/pam.d/login; then
    sudo sed -i '/^password/ i session    optional     pam_gnome_keyring.so auto_start' /etc/pam.d/login
fi

# Brightness control
sudo usermod -aG i2c jole
if [ ! -e "/etc/modules-load.d/ic2-dev.conf" ]; then
    cat <<EOF | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null
i2c-dev
EOF
fi

# Sensors
if [ ! -e "/etc/modules-load.d/nct6775.conf" ]; then
    echo nct6775 | sudo tee /etc/modules-load.d/nct6775.conf
    echo "options nct6775 force_id=0xd802" | sudo tee /etc/modprobe.d/nct6775.conf
fi

# Dotfiles
sudo pacman -S --noconfirm --needed stow
if [ ! -e "$HOME/.dotfiles" ]; then
    git clone --recurse-submodules https://github.com/drjole/dotfiles "$HOME/.dotfiles"
    pushd "$HOME/.dotfiles"
    git remote set-url origin git@github.com:drjole/dotfiles.git
    find . -mindepth 1 -maxdepth 1 -type d -not -name .git -printf "%f\n" | xargs -I {} mkdir -p "$HOME"/{}
    stow .
    popd
fi
bat cache --build

# Shell
sudo chsh --shell /bin/zsh jole

# Theming
yay -S --noconfirm --needed catppuccin-gtk-theme-mocha catppuccin-cursors-mocha yaru-icon-theme

# Bluetooth
sudo pacman -S --noconfirm --needed blueman bluez bluez-utils
sudo systemctl enable --now bluetooth.service

# Development environments
sudo pacman -S --noconfirm --needed mise
mise trust "$HOME/.dotfiles/.config/mise/config.toml"
mise use -g usage
mise use -g node
mise use -g ruby

# reditus
sudo pacman -S --noconfirm --needed pre-commit mkcert postgresql keepassxc chromium

# Firefox
# Set `intl.regional_prefs.use_os_locales` to true to use german date formats in firefox while keeping language at english

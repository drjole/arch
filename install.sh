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
if ! grep -q '^Color' /etc/pacman.conf; then
    sudo sed -i '/^\[options\]/a Color' /etc/pacman.conf
fi
if ! grep -q '^ILoveCandy' /etc/pacman.conf; then
    sudo sed -i '/^\[options\]/a ILoveCandy' /etc/pacman.conf
fi

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
    hyprland uwsm libnewt xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprpolkitagent hypridle hyprpaper waybar rofi dunst hyprlock wl-clipboard hyprsunset grim slurp qt5-wayland qt6-wayland \
    brightnessctl alacritty firefox nautilus sushi ffmpegthumbnailer spotify-launcher discord pavucontrol gimp inkscape libreoffice-still nextcloud-client signal-desktop vlc zathura zathura-pdf-poppler xournalppsteam teamspeak3 gnome-keyring \
    gnome-themes-extra \
    noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-font-awesome otf-font-awesome \
    kvantum-qt5 \
    zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting \
    neovim fzf starship eza bat htop tmux ddcutil man-db ripgrep fd lazygit jq unzip \
    pacman-contrib

# yay
if ! command -v yay >/dev/null 2>&1; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    pushd /tmp/yay
    makepkg -si
    popd
fi

# Configure dconf to use a text-based file
sudo mkdir -p /etc/dconf/profile
echo "service-db:keyfile/user" | sudo tee -a /etc/dconf/profile/user

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

# Seamless login
./seamless-login.sh

# Don't require network interfaces to be routable for boot
sudo systemctl disable --now systemd-networkd-wait-online

# Services
systemctl --user enable --now hyprpaper
systemctl --user enable --now hyprpolkitagent
systemctl --user enable --now hyprsunset
systemctl --user enable --now waybar

# Docker
sudo pacman -S --noconfirm --needed docker docker-compose docker-buildx
sudo systemctl enable --now docker.service
sudo usermod -a -G docker jole

# Shell
sudo chsh --shell /bin/zsh jole

# Theming
yay -S --noconfirm --needed yaru-icon-theme
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru-purple-dark"

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

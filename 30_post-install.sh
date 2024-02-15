#!/bin/sh

set -e

source ./00_config.sh

# yay
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg --noconfirm -si

# Terminal/shell tools
sudo pacman --noconfirm -S bat eza fzf htop lazygit ripgrep starship tmux zsh-completions

# Xorg related packages
sudo pacman --noconfirm -S xorg xorg-xinit xclip xdotool

# Window manager related packages
sudo pacman --noconfirm -S dex dunst i3 i3lock i3status-rust maim numlockx picom xss-lock

# Graphical applications
sudo pacman --noconfirm -S alacritty firefox network-manager-applet nextcloud-client obsidian redshift signal-desktop spotify-launcher vlc \
  python-gobject # python-gobject is required for redshift for some reason

# Audio
sudo pacman --noconfirm -S pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack

# Programming languages
sudo pacman --noconfirm -S cmake go nodejs npm rustup

# Docker
sudo pacman --noconfirm -S docker docker-compose
sudo systemctl enable --now docker
sudo usermod -a -G docker $ARCH_INSTALL_USERNAME

# reditus
sudo pacman --noconfirm -S mariadb-libs mkcert pre-commit keepassxc
yay --noconfirm -S rbenv ruby-build
rbenv install 3.1.4
rbenv global 3.1.4
rbenv rehash
gem install solargraph solargraph-rails \
  solargraph-rails-patch-for-rails71 # solargraph does not work well with Rails 7.1

# Rust
rustup default stable

# LSPs
sudo pacman --noconfirm -S gopls lua-language-server prettier python-lsp-server shfmt texlab yaml-language-server
rustup component add rust-analyzer
npm install -g dockerfile-language-server-nodejs stimulus-language-server

# Syncthing
sudo pacman --noconfirm -S syncthing
systemctl --user enable --now syncthing

# Theming
sudo pacman --noconfirm -S hicolor-icon-theme kvantum noto-fonts noto-fonts-emoji papirus-icon-theme plymouth ttf-liberation
yay --noconfirm -S catppuccin-cursors-mocha catppuccin-gtk-theme-mocha kvantum-theme-catppuccin-git qt5-styleplugins
# Catppuccin GRUB
yay --noconfirm -S catppuccin-mocha-grub-theme-git
sudo cp -r /usr/share/grub/themes/catppuccin-mocha /boot/grub/themes/
sudo grub-mkconfig -o /boot/grub/grub.cfg
# Catppuccin Plymouth
yay --noconfirm -S plymouth-theme-catppuccin-mocha-git
sudo sed -i '/^HOOKS=(/s/base/base plymouth/' /etc/mkinitcpio.conf
sudo mkinitcpio -P

# Automatic login
sudo cat <<EOF >/etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
Type=idle
ExecStart=
ExecStart=-/usr/bin/agetty --skip-login --nonewline --noissue --autologin $ARCH_INSTALL_USERNAME --noclear %I \$TERM
Environment=XDG_SESSION_TYPE=x11
EOF
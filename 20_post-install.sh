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
sudo pacman --noconfirm -S dex dunst i3 i3lock i3status-rust maim numlockx picom rofi xss-lock

# Graphical applications
sudo pacman --noconfirm -S alacritty firefox network-manager-applet nextcloud-client obsidian redshift signal-desktop spotify-launcher vlc \
  python-gobject # python-gobject is required for redshift for some reason

# Audio
sudo pacman --noconfirm -S pipewire pipewire-audio pipewire-alsa pipewire-pulse
yes | sudo pacman --noconfirm -S pipewire-jack

# Programming languages
sudo pacman --noconfirm -S cmake go nodejs npm rustup

# Docker
sudo pacman --noconfirm -S docker docker-compose
sudo systemctl enable --now docker
sudo usermod -a -G docker $USER

# reditus
sudo pacman --noconfirm -S mariadb-libs mkcert pre-commit keepassxc
yay --noconfirm -S rbenv ruby-build
rbenv install 3.1.4
rbenv global 3.1.4
rbenv rehash
eval "$(rbenv init - zsh)"
gem install solargraph solargraph-rails \
  solargraph-rails-patch-for-rails71 # solargraph does not work well with Rails 7.1

# Rust
rustup default stable

# LSPs
sudo pacman --noconfirm -S gopls lua-language-server prettier python-lsp-server shfmt texlab yaml-language-server
rustup component add rust-analyzer
npm install -g --prefix ~/.local dockerfile-language-server-nodejs stimulus-language-server

# Syncthing
sudo pacman --noconfirm -S syncthing
systemctl --user enable --now syncthing

# Theming
sudo pacman --noconfirm -S hicolor-icon-theme kvantum ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji papirus-icon-theme plymouth ttf-liberation
yay --noconfirm -S catppuccin-cursors-mocha catppuccin-gtk-theme-mocha kvantum-theme-catppuccin-git qt5-styleplugins
# Catppuccin GRUB
yay --noconfirm -S catppuccin-mocha-grub-theme-git
sudo cp -r /usr/share/grub/themes/catppuccin-mocha /boot/grub/themes/
sudo sed -i '/#GRUB_THEME/aGRUB_THEME="/boot/grub/themes/catppuccin-mocha/theme.txt"' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
# Catppuccin Plymouth
yay --noconfirm -S plymouth-theme-catppuccin-mocha-git
sudo sed -i '/^HOOKS=(/s/base/base plymouth/' /etc/mkinitcpio.conf
sudo mkinitcpio -P

# Automatic login
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
cat <<EOF | sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf >/dev/null
[Service]
Type=idle
ExecStart=
ExecStart=-/usr/bin/agetty --skip-login --nonewline --noissue --autologin $USER --noclear %I \$TERM
Environment=XDG_SESSION_TYPE=x11
EOF

# Dotfiles
sudo pacman --noconfirm -S stow
git clone --recurse-submodules https://github.com/drjole/dotfiles ~/.dotfiles
cd ~/.dotfiles
# Create directories so that stow does not create symlinks to the top level directories
find . -mindepth 1 -maxdepth 1 -type d -not -name .git -printf "%f\n" | xargs -I {} mkdir -p "$HOME"/{}
stow .

# Final steps
bat cache --build

echo "Now reboot the system"

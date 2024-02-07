#!/bin/sh

set -e

./config.sh

# Install yay
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg --noconfirm -si

# Install applications and tools from the official repositories
sudo pacman --noconfirm -S \
  bat cmake dunst eza fzf htop ripgrep starship tmux zsh-completions \
  xorg xorg-xinit xclip xdotool maim numlockx plymouth xss-lock \
  i3 i3lock i3status-rust dex picom \
  network-manager-applet redshift python-gobject \
  kvantum ttf-liberation noto-fonts noto-fonts-emoji hicolor-icon-theme papirus-icon-theme \
  alacritty firefox nextcloud-client obsidian signal-desktop spotify-launcher vlc \
  pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack \
  go gopls lazygit lua-language-server nodejs npm prettier python-lsp-server shfmt rustup texlab yaml-language-server

# Docker
sudo pacman --noconfirm -S docker docker-compose
sudo systemctl enable --now docker
sudo usermod -a -G docker $USERNAME

# reditus
sudo pacman --noconfirm -S mariadb-libs mkcert pre-commit keepassxc
yay --noconfirm -S rbenv ruby-build
rbenv install 3.1.4
rbenv global 3.1.4
rbenv rehash
gem install solargraph solargraph-rails solargraph-rails-patch-for-rails71
# Inside ~/code/reditus/intern:
# bundle
# yard gems

# Rust
rustup default stable

# LSPs
rustup component add rust-analyzer
npm install -g dockerfile-language-server-nodejs stimulus-language-server

# Greetd
sudo pacman --noconfirm -S greetd
sudo systemctl enable greetd

# Syncthing
sudo pacman --noconfirm -S syncthing
systemctl --user enable --now syncthing

# Theming
yay --noconfirm -S catppuccin-gtk-theme-mocha catppuccin-cursors-mocha kvantum-theme-catppuccin-git qt5-styleplugins
# Catppuccin GRUB
yay --noconfirm -S catppuccin-mocha-grub-theme-git
sudo cp -r /usr/share/grub/themes/catppuccin-mocha /boot/grub/themes/
sudo grub-mkconfig -o /boot/grub/grub.cfg
# Catppuccin Plymouth
yay --noconfirm -S plymouth-theme-catppuccin-mocha-git
sudo sed -i '/^HOOKS=(/s/base/base plymouth/' /etc/mkinitcpio.conf
sudo mkinitcpio -P

# Automatic login
cat <<EOF >/etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
Type=idle
ExecStart=
ExecStart=-/usr/bin/agetty --skip-login --nonewline --noissue --autologin $USERNAME --noclear %I \$TERM
Environment=XDG_SESSION_TYPE=x11
EOF

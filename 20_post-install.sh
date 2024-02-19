#!/bin/sh

set -e

# Ask for the sudo password upfront and make sure it is not asked for again
sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# Enable parallel downloads in pacman
sudo sed -i '/^#ParallelDownloads/s/#//' /etc/pacman.conf

# Enable multi-threading in makepkg and set it to use all available cores
sudo sed -i "/^MAKEFLAGS=/cMAKEFLAGS=\"-j$(nproc)\"" /etc/makepkg.conf

# Install yay
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg --noconfirm -si

pacman_packages=(
    # Terminal/shell tools
    bat eza fzf htop lazygit ripgrep starship stow tmux zsh-completions

    # Xorg related packages
    xorg xorg-xinit xclip xdotool

    # Audio
    pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack

    # Window manager related packages
    dex dunst i3 i3lock i3status-rust maim numlockx picom rofi xss-lock

    # Desktop applications
    alacritty firefox network-manager-applet nextcloud-client obsidian pavucontrol redshift signal-desktop spotify-launcher syncthing vlc
    # python-gobject is required for redshift for some reason
    python-gobject

    # Theming
    hicolor-icon-theme kvantum ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji papirus-icon-theme plymouth ttf-liberation

    # Programming languages
    cmake go nodejs npm rustup

    # LSPs
    gopls lua-language-server prettier python-lsp-server shfmt texlab yaml-language-server

    # Docker
    docker docker-compose
    
    # reditus
    mariadb-libs mkcert pre-commit keepassxc
)

yay_packages=(
    # Theming
    catppuccin-cursors-mocha catppuccin-gtk-theme-mocha kvantum-theme-catppuccin-git qt5-styleplugins

    # Catppuccin GRUB
    catppuccin-mocha-grub-theme-git

    # Catppuccin Plymouth
    plymouth-theme-catppuccin-mocha-git

    # reditus
    rbenv ruby-build
)

# Install all the tools
sudo pacman --noconfirm -S "${packages[@]}"
yay --noconfirm -S "${yay_packages[@]}"

# Docker
sudo systemctl enable --now docker
sudo usermod -a -G docker $USER

# reditus
rbenv install 3.1.4
rbenv global 3.1.4
rbenv rehash
eval "$(rbenv init - zsh)"
gem install solargraph solargraph-rails \
  solargraph-rails-patch-for-rails71 # solargraph does not work well with Rails 7.1

# Rust
rustup default stable

# LSPs
rustup component add rust-analyzer
# Install with prefix ~/.local which then must be set in the npm_config_prefix environment variable
npm install -g --prefix ~/.local dockerfile-language-server-nodejs stimulus-language-server

# Syncthing
systemctl --user enable --now syncthing

# Theming
# Catppuccin TTY
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/s/"$/ vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166 vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173 vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"/' /etc/default/grub
# Catppuccin GRUB
sudo cp -r /usr/share/grub/themes/catppuccin-mocha /boot/grub/themes/
sudo sed -i '/#GRUB_THEME/aGRUB_THEME="/boot/grub/themes/catppuccin-mocha/theme.txt"' /etc/default/grub
# Catppuccin Plymouth
sudo sed -i '/^HOOKS=(/s/base/base plymouth/' /etc/mkinitcpio.conf
sudo sed -i '/^#\[Daemon\]/s/#//' /etc/plymouth/plymouthd.conf
sudo sed -i '/^#Theme=/cTheme=catppuccin-mocha' /etc/plymouth/plymouthd.conf

# Update the GRUB configuration and the initramfs
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Bat
bat cache --build

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
git clone --recurse-submodules https://github.com/drjole/dotfiles ~/.dotfiles
cd ~/.dotfiles
# Create directories so that stow does not create symlinks to the top level directories
find . -mindepth 1 -maxdepth 1 -type d -not -name .git -printf "%f\n" | xargs -I {} mkdir -p "$HOME"/{}
stow .

echo "Now reboot the system"

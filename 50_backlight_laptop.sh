#!/bin/sh

set -e

source 00_config.sh

sudo pacman --noconfirm -S acpilight
sudo usermod -aG video "$ARCH_INSTALL_USERNAME"
sudo cat <<EOF >/etc/udev/rules.d/90-backlight.rules
SUBSYSTEM=="backlight", ACTION=="add", \
  RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness", \
  RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF

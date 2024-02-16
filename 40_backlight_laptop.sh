#!/bin/sh

set -e

sudo pacman --noconfirm -S acpilight
sudo usermod -aG video "$USER"
sudo cat <<EOF >/etc/udev/rules.d/90-backlight.rules
SUBSYSTEM=="backlight", ACTION=="add", \
  RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness", \
  RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF

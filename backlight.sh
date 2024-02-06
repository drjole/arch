#!/bin/sh

set -e

./config.sh

sudo pacman -S acpilight

cat <<EOF >/etc/udev/rules.d/90-backlight.rules
SUBSYSTEM=="backlight", ACTION=="add", \
  RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness", \
  RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF

sudo usermod -a -G video "$USERNAME"

#!/bin/bash

sudo cat <<EOF >/etc/X11/xorg.conf.d/30-touchpad.conf
Section "InputClass"
    Identifier "devname"
    Driver "libinput"
    Option "ClickMethod" "clickfinger"
    Option "NaturalScrolling" "true"
    Option "Tapping" "on"
EndSection
EOF

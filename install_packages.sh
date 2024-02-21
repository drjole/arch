#!/bin/bash

# The user can provide --noconfirm to the script which is passed both to pacman and yay
noconfirm=""
if [[ "$1" == "--noconfirm" ]]; then
  noconfirm="--noconfirm"
fi

# Prepare and install packages with pacman
packages_pacman=$(sed '/^#/d;/^[[:space:]]*$/d' packages.pacman)
if [ -n "$packages_pacman" ]; then
  echo "$packages_pacman" | sudo pacman $noconfirm -S --needed -
fi

# Prepare and install packages with yay
packages_yay=$(sed '/^#/d;/^[[:space:]]*$/d' packages.yay)
if [ -n "$packages_yay" ]; then
  echo "$packages_yay" | yay $noconfirm -S --needed -
fi

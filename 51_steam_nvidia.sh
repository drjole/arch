#!/bin/bash

set -e

./50_steam_pre.sh

# Install the 32-bit libraries for the Nvidia GPU
sudo pacman --noconfirm -S nvidia-utils lib32-nvidia-utils

./52_steam_post.sh

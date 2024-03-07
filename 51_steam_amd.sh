#!/bin/bash

set -e

./50_steam_pre.sh

# Install the 32-bit libraries for the AMD GPU
sudo pacman --noconfirm -S lib32-mesa vulkan-radeon lib32-vulkan-radeon

./52_steam_post.sh

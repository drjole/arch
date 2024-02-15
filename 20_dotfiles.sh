#!/bin/sh

set -e

sudo pacman --noconfirm -S git stow
git clone https://github.com/drjole/dotfiles ~/.dotfiles
cd ~/.dotfiles
stow .

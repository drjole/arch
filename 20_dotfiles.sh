#!/bin/sh

set -e

sudo pacman --noconfirm -S git stow
git clone git@github.com:drjole/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow .

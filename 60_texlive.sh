#!/bin/bash

set -e

# Install ghostscript which is required for eps to pdf conversion
sudo pacman --noconfirm -S ghostscript

# Install TeX Live
cd ./install-tl-20231025
sudo perl ./install-tl --no-interaction

# Install missing CPAN modules for latexindent
yes | sudo cpan YAML::Tiny File::HomeDir

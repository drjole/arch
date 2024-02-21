#!/bin/bash

sed '/^#/d;/^$/d' packages.pacman | sudo pacman --noconfirm -S --needed -
sed '/^#/d;/^$/d' packages.yay | yay --noconfirm -S --needed -

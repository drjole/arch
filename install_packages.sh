#!/bin/bash

set -e

# This script installs packages as defeined in packages files.
#
# The file name of a packages file is expected to be packages.pacman.$(hostname) or packages.yay.$(hostname) depending on the package manager to use.
# If the file ends in .common, it is used for all hosts.
#
# The packages files should contain a list of packages and package groups, one per line.
# Lines starting with # are ignored. Empty lines are ignored.
#
# Package names starting with @ are treated as package groups.
# These lines can be followed by 'minus package1 package2 ...' to exclude packages from the group.

# The user can provide --noconfirm to the script which is passed both to pacman and yay
noconfirm=""
if [[ "$1" == "--noconfirm" ]]; then
  noconfirm="--noconfirm"
fi

# A function for parsing a packages file.
# Given the file name, it reads the file and returns a list of packages to install.
parse_packages_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    return
  fi

  local packages=()
  while read -r line; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
      continue
    fi
    if [[ "$line" == @* ]]; then
      group_packages=($(parse_group_line "$line"))
      packages=(${packages[@]} ${group_packages[@]})
    else
      packages+=("$line")
    fi
  done <"$file"

  echo "${packages[@]}"
}

# A function for parsing a '@group minus package1 package2 ...' line.
# Given the line as the first argument, it returns a list of packages to install from the group excluding the specified packages.
parse_group_line() {
  local line="$1"
  local group_name=$(echo "$line" | cut -d' ' -f1 | sed 's/^@//')
  local group_packages=($(pacman -Sgq "$group_name"))
  local minus_packages=$(echo "$line" | sed -n 's/^@.* minus //p')
  for minus_package in $minus_packages; do
    group_packages=($(echo "${group_packages[@]}" | sed "s/\b$minus_package\b//g"))
  done
  echo "${group_packages[@]}"
}

# Install packages.
# The package manager is passed as the first argument.
install_packages() {
  local package_manager="$1"
  local packages_common=($(parse_packages_file "packages.$package_manager.common"))
  local packages_host=($(parse_packages_file "packages.$package_manager.$(hostname)"))
  local packages=()
  if [[ ${#packages_common[@]} -gt 0 ]]; then
    packages=(${packages[@]} ${packages_common[@]})
  fi
  if [[ ${#packages_host[@]} -gt 0 ]]; then
    packages=(${packages[@]} ${packages_host[@]})
  fi

  if [[ "$package_manager" == "pacman" ]]; then
    sudo pacman $noconfirm -S --needed "${packages[@]}"
  fi
  if [[ "$package_manager" == "yay" ]]; then
    yay $noconfirm -S --needed "${packages[@]}"
  fi
}

install_packages "pacman"
install_packages "yay"

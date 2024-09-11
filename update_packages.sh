sudo pacman -Syu
yay -Syu
cargo install-update --all
gem update
xargs -I {} go install -v {} <packages.go.common
local_go_packages_file="packages.go.$(hostname)"
[ -f "$local_go_packages_file" ] && xargs -I {} go install -v {} <"$local_go_packages_file"
npm update -g

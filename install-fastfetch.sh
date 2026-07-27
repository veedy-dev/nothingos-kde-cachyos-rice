#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch"
image_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fastfetch/images"

install -d "$config_dir" "$image_dir"
if [[ -f "$config_dir/config.jsonc" ]]; then
    cp -a "$config_dir/config.jsonc" "$config_dir/config.jsonc.before-nothingos"
fi
install -m 0644 "$repo_dir/fastfetch.jsonc" "$config_dir/config.jsonc"
install -m 0644 "$repo_dir/assets/fastfetch/cachyos-nothing-white.png" \
    "$image_dir/cachyos-nothing-white.png"
printf 'Installed NothingOS Fastfetch preset. Run: fastfetch\n'


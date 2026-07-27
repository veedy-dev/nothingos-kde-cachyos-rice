#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
install_root="$data_home/nothingos-kde-rice"
backup_root="$state_home/nothingos-kde-rice/backups"
timestamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="$backup_root/$timestamp"

dry_run=false
install_packages=true
layout_only=false
assume_yes=false

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]
  --dry-run       Print the planned actions without changing files
  --no-packages   Skip pacman dependency installation
  --layout-only   Apply only the Plasma layout (still creates a backup)
  --yes           Do not ask for confirmation
  -h, --help      Show this help
EOF
}

while (($#)); do
    case "$1" in
        --dry-run) dry_run=true ;;
        --no-packages) install_packages=false ;;
        --layout-only) layout_only=true; install_packages=false ;;
        --yes) assume_yes=true ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

run() {
    printf '+'
    printf ' %q' "$@"
    printf '\n'
    if ! $dry_run; then
        "$@"
    fi
}

copy_tree() {
    local source="$1" destination="$2"
    run install -d "$destination"
    if $dry_run; then
        printf '+ cp -a %q/. %q/\n' "$source" "$destination"
    else
        cp -a "$source/." "$destination/"
    fi
}

if [[ "${XDG_CURRENT_DESKTOP:-}" != *KDE* && "${XDG_CURRENT_DESKTOP:-}" != *Plasma* ]]; then
    printf 'Warning: this does not appear to be a KDE Plasma session.\n' >&2
fi
if [[ ! -f /etc/arch-release ]]; then
    printf 'Warning: this installer is designed for CachyOS/Arch Linux.\n' >&2
fi
if ! $assume_yes && ! $dry_run; then
    printf 'This will replace the current Plasma panels and desktop widgets.\n'
    read -r -p 'Continue after creating a backup? [y/N] ' answer
    case "$answer" in y|Y|yes|YES) ;; *) printf 'Cancelled.\n'; exit 0 ;; esac
fi

printf '\n==> Backing up KDE configuration to %s\n' "$backup_dir"
run install -d "$backup_dir/config"
for file in kdeglobals kcminputrc kglobalshortcutsrc kscreenlockerrc kwinrc \
            plasmarc plasma-org.kde.plasma.desktop-appletsrc powerdevilrc; do
    if [[ -f "$config_home/$file" ]]; then
        run cp -a "$config_home/$file" "$backup_dir/config/$file"
    fi
done

if $layout_only; then
    printf '\n==> Layout-only mode\n'
else
    if $install_packages; then
        printf '\n==> Installing build/runtime dependencies\n'
        run sudo pacman -S --needed plasma-workspace kwin fastfetch cmake \
            qt6-base gcc
    fi

    printf '\n==> Installing themes, widgets, font, wallpaper and Fastfetch\n'
    copy_tree "$repo_dir/plasmoids" "$data_home/plasma/plasmoids"
    copy_tree "$repo_dir/theme/icons" "$data_home/icons"
    copy_tree "$repo_dir/theme/cursors" "$data_home/icons"
    copy_tree "$repo_dir/theme/plasma" "$data_home/plasma/desktoptheme"
    copy_tree "$repo_dir/theme/color-schemes" "$data_home/color-schemes"
    copy_tree "$repo_dir/kwin/effects" "$data_home/kwin/effects"
    copy_tree "$repo_dir/kwin/scripts" "$data_home/kwin/scripts"

    run install -d "$data_home/fonts/NothingOS"
    run install -m 0644 "$repo_dir/fonts/ndot.ttf" \
        "$data_home/fonts/NothingOS/ndot.ttf"
    run install -d "$data_home/wallpapers/NothingOS-Airplane/contents/images"
    run install -m 0644 \
        "$repo_dir/assets/wallpaper/nothingos-airplane-5120x1440.jpg" \
        "$data_home/wallpapers/NothingOS-Airplane/contents/images/5120x1440.jpg"

    if $dry_run; then
        printf '+ %q/install-fastfetch.sh\n' "$repo_dir"
    else
        "$repo_dir/install-fastfetch.sh"
    fi
    run fc-cache -f

    printf '\n==> Building the independent widget edge controller\n'
    build_dir="$repo_dir/native/edge-groups/build"
    run cmake -S "$repo_dir/native/edge-groups" -B "$build_dir" \
        -DCMAKE_BUILD_TYPE=Release
    run cmake --build "$build_dir" --parallel
    run install -d "$HOME/.local/libexec"
    run install -m 0755 "$build_dir/nothingos-edge-groups" \
        "$HOME/.local/libexec/nothingos-edge-groups"
    run install -d "$config_home/systemd/user"
    run install -m 0644 "$repo_dir/systemd/nothingos-edge-groups.service" \
        "$config_home/systemd/user/nothingos-edge-groups.service"

    printf '\n==> Applying KDE and OLED-safe preferences\n'
    run kwriteconfig6 --file kdeglobals --group General --key ColorScheme \
        LetMinimalDark-Theme
    run kwriteconfig6 --file kdeglobals --group Icons --key Theme YAMIS
    run kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Breeze
    run kwriteconfig6 --file plasmarc --group Theme --key name \
        LetMinimalDark-Theme
    run kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme \
        We10XOS-cursors

    run kwriteconfig6 --file kwinrc --group Desktops --key Number 3
    run kwriteconfig6 --file kwinrc --group Desktops --key Rows 1
    run kwriteconfig6 --file kwinrc --group Effect-hidecursor \
        --key HideOnTyping --type bool false
    run kwriteconfig6 --file kwinrc --group Effect-hidecursor \
        --key InactivityDuration 15
    for plugin in bouncingWindows hidecursor minimizeall nothingos-edge-groups; do
        run kwriteconfig6 --file kwinrc --group Plugins \
            --key "${plugin}Enabled" --type bool true
    done
    run kwriteconfig6 --file kwinrc --group Plugins \
        --key scaleEnabled --type bool false
    run kwriteconfig6 --file kwinrc --group Plugins \
        --key shapecornersEnabled --type bool false
    run kwriteconfig6 --file kwinrc --group Plugins \
        --key kwin4_effect_shapecornersEnabled --type bool false

    run kwriteconfig6 --file kglobalshortcutsrc --group kwin \
        --key MinimizeAll 'Meta+D,none,Minimize all windows'
    run kwriteconfig6 --file kglobalshortcutsrc --group kwin \
        --key 'Show Desktop' 'none,Meta+D,Peek at Desktop'

    run kwriteconfig6 --file powerdevilrc --group AC --group Display \
        --key TurnOffDisplayWhenIdle --type bool true
    run kwriteconfig6 --file powerdevilrc --group AC --group Display \
        --key TurnOffDisplayIdleTimeoutSec 60

    wallpaper_path="$data_home/wallpapers/NothingOS-Airplane/contents/images/5120x1440.jpg"
    wallpaper_uri="file://$wallpaper_path"
    run kwriteconfig6 --file kscreenlockerrc --group Greeter \
        --key WallpaperPlugin org.kde.image
    run kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper \
        --group org.kde.image --group General --key Image "$wallpaper_uri"
    run kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper \
        --group org.kde.image --group General --key PreviewImage "$wallpaper_uri"
fi

printf '\n==> Applying Plasma layout\n'
wallpaper_path="$data_home/wallpapers/NothingOS-Airplane/contents/images/5120x1440.jpg"
wallpaper_uri="file://$wallpaper_path"
run install -d "$install_root"
if $dry_run; then
    printf '+ render %q with wallpaper %q\n' "$repo_dir/layout/layout.js" "$wallpaper_uri"
else
    sed "s|__WALLPAPER_URI__|$wallpaper_uri|g" \
        "$repo_dir/layout/layout.js" > "$install_root/layout.js"
fi

if $dry_run; then
    printf '+ qdbus6 org.kde.plasmashell /PlasmaShell evaluateScript < layout.js\n'
else
    if ! qdbus6 org.kde.plasmashell /PlasmaShell \
        org.kde.PlasmaShell.evaluateScript \
        "$(cat "$install_root/layout.js")"; then
        printf 'Could not apply the live layout; log in to Plasma and rerun.\n' >&2
        exit 1
    fi
fi

if ! $layout_only; then
    run systemctl --user daemon-reload
    run systemctl --user enable --now nothingos-edge-groups.service
    run qdbus6 org.kde.KWin /KWin reconfigure
fi

printf '\n==> Installing restore helper\n'
run install -d "$install_root"
if $dry_run; then
    printf '+ generate %q\n' "$install_root/restore-latest.sh"
else
    cat > "$install_root/restore-latest.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
backup_dir=$(printf '%q' "$backup_dir")
config_home=$(printf '%q' "$config_home")
for source in "\$backup_dir/config/"*; do
    [[ -e "\$source" ]] || continue
    cp -a "\$source" "\$config_home/\$(basename "\$source")"
done
qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
systemctl --user restart plasma-plasmashell.service
printf 'Restored KDE configuration from %s\\n' "\$backup_dir"
EOF
    chmod 0755 "$install_root/restore-latest.sh"
fi

printf '\nDone. Log out and back in once for a fully clean reload.\n'
printf 'Backup: %s\n' "$backup_dir"
printf 'Restore: %s/restore-latest.sh\n' "$install_root"


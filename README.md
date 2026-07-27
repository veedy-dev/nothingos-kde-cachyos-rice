# NothingOS-inspired KDE Plasma rice

A reproducible version of my monochrome NothingOS-style CachyOS desktop,
tuned for KDE Plasma 6, Wayland, OLED displays, and a 5120×1440 Odyssey G9.

![Desktop preview](screenshots/nothingos-kde-g9.png)

## Highlights

- square, OLED-black status panel and medium dynamic application dock
- grouped left/right widgets that independently hide after 10 seconds
- calendar, Jakarta weather, Tokyo world clock, notes, CPU, RAM, and a wide
  media player
- compact clickable `1 2 3` virtual desktop pager
- Nothing dot font throughout the widgets and panel clock
- matching desktop and lock-screen wallpaper
- quick but visible bouncing close animation
- cursor hiding after 15 seconds and display power-off after 60 seconds
- a shareable monochrome Fastfetch preset
- automatic timestamped backup plus a generated restore script

## Supported setup

- CachyOS or Arch Linux
- KDE Plasma **6.7+**
- a Plasma Wayland session
- one primary display; the layout scales from 1920×1080 through 5120×1440

The 32:9 G9 layout is the reference target. Other resolutions use the same
edge-column design with proportional margins.

## Install

Review the script first—this changes your Plasma layout and KDE preferences.

```bash
git clone https://github.com/veedy-dev/nothingos-kde-cachyos-rice.git
cd nothingos-kde-cachyos-rice
./install.sh
```

Useful modes:

```bash
./install.sh --dry-run        # show actions without changing anything
./install.sh --no-packages    # do not run pacman
./install.sh --layout-only    # reinstall only the Plasma layout
```

The installer backs up affected KDE files under:

```text
~/.local/state/nothingos-kde-rice/backups/<timestamp>/
```

Restore the most recent backup with:

```bash
~/.local/share/nothingos-kde-rice/restore-latest.sh
```

Log out and back in once after installation so KWin, fonts, and autostarted
services are all loaded consistently.

## Fastfetch only

```bash
./install-fastfetch.sh
fastfetch
```

The preset is derived from LierB's Groups concept and restyled to match this
rice. It is resolution- and hardware-independent.

## Personalizing

- Change the city and time zone near the top of `layout/layout.js`.
- Change pinned dock apps in `layout/layout.js`.
- Change the edge hide delay in `native/edge-groups/main.cpp` (default 10 s).
- Change display timeout in `install.sh` (default 60 s).

See [docs/COMPONENTS.md](docs/COMPONENTS.md) for the exact component list and
[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues.

## Credits and licensing

This rice combines work from several KDE community projects. See
[THIRD_PARTY.md](THIRD_PARTY.md). The repository's original scripts and
configuration are GPL-3.0-or-later; bundled components retain their upstream
licenses.

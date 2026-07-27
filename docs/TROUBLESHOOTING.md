# Troubleshooting

## Widgets or panels do not appear

Log out and back in. If needed:

```bash
systemctl --user restart plasma-plasmashell.service
systemctl --user restart nothingos-edge-groups.service
```

## Left/right groups do not reveal

Check the controller:

```bash
systemctl --user status nothingos-edge-groups.service
journalctl --user -u nothingos-edge-groups.service -b
```

Move the pointer against the left or right edge over any member of that group.

## Layout is too small or too large

The script scales margins and keeps practical widget sizes. KDE's global
display scale still affects the apparent size. Start with 100% on a 5120×1440
G9 and adjust in System Settings → Display & Monitor.

## Restore the previous desktop

```bash
~/.local/share/nothingos-kde-rice/restore-latest.sh
```

The restore is intentionally file-based and does not remove unrelated packages.


# TODO

## Wire up XDG user-dirs re-pointing?

`xdg/user-dirs.dirs` re-points the XDG dirs (lowercased under `$HOME`;
downloads/templates/public moved to `/nobackup`), but it's **not applied**: no
link entry in `install.conf.yaml`, and the live `~/.config/user-dirs.dirs` still
holds stock defaults.

Decide whether to wire it up. If yes:

- Add a link in `install.conf.yaml`: `~/.config/user-dirs.dirs: xdg/user-dirs.dirs`.
- Ensure `/nobackup/{downloads,templates,public}` exist first (mkdir step).
- `xdg-user-dirs-update` overwrites this file on login — the symlink target
  survives, but verify it isn't clobbered. Consider `enabled=False` in
  `~/.config/user-dirs.conf` to stop auto-updates.

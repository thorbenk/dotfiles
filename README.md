# dotfiles

Symlinks managed by [dotbot](https://github.com/anishathalye/dotbot)
(`install.conf.yaml`); CLI tools installed from GitHub releases via `install.py`
against a lockfile (`install.lock.json`).

## Install

```sh
git clone git@github.com:thorbenk/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
git submodule update --init --recursive
./install                 # dotbot: symlink dotfiles + run install.py (CLI tools)
chsh -s "$(which zsh)"    # make zsh the login shell
```

## Assumptions

- The repo lives at `~/code/dotfiles`. `zshrc` (`DOTFILES_DIR`), `tmux.conf`
  and `applications/dictation-indicator.desktop` hardcode that path; the
  `.desktop` file also hardcodes the home dir (`/home/kroeger`), since
  `.desktop` files can't expand `$HOME`.

## Per-machine differences

Host-specific behavior is keyed on the hostname, in three places:

- `install.py`: `Dep(..., only_on=(...))` / `not_on=(...)` picks which tools a
  host gets.
- `install.conf.yaml`: `if: '[ "$(hostname)" ... ]'` on individual links.
- `zshrc`: `hostname` checks for shell tweaks.

Per-machine state that isn't in the repo:

- `~/.claude/settings.host.json`: layered over the shared Claude Code settings
  by the `claude` wrapper in `zshrc` (e.g. to skip permission prompts).
- `~/.codex/config.toml`: copied from `codex/config.base.toml` on first
  install, then owned by the machine (Codex writes project trust into it).

## Managing tools

```sh
./install.py --check         # compare installed vs. locked versions
./install.py --show-lock     # print the lockfile
./install.py --update-lock   # bump lockfile to latest GitHub releases
```

## Tips & tricks

- [T570](t570.md)
- [command line](cmdline.md)

# dotfiles

Symlinks managed by [dotbot](https://github.com/anishathalye/dotbot)
(`install.conf.yaml`); CLI tools installed from GitHub releases via `install.py`
against a lockfile (`install.lock.json`).

## Install

```sh
git clone git@github.com:thorbenk/dotfiles.git
cd dotfiles
git submodule update --init --recursive
./install                 # dotbot: symlink dotfiles + run install.py (CLI tools)
chsh -s "$(which zsh)"    # make zsh the login shell
```

## Managing tools

```sh
./install.py --check         # compare installed vs. locked versions
./install.py --show-lock     # print the lockfile
./install.py --update-lock   # bump lockfile to latest GitHub releases
```

## Tips & tricks

- [T570](t570.md)
- [command line](cmdline.md)

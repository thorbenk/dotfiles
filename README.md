# Installation

```
git clone https://github.com/thorbenk/dotfiles
git submodule init
git submodule update

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

cd dotfiles
./make-symlinks.sh

vim +PlugInstall +qall

chsh -s $(which zsh)
```

## xdg user directories

The XDG user dirs (e.g. desktop, documents) will point to different locations
wrt. the defaults. Consider deleting the previously generated directories
"Downloads", "Public", "Templates", etc.

# Tips & Tricks

- [Vim](vim.md)
- [T570](t570.md)
- [command line](cmdline.md)


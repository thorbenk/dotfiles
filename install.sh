set -e

if ! node --version &> /dev/null ; then
    echo "install nodejs"
    exit
fi
if ! fzf --version &> /dev/null ; then
    echo "install fzf"
    exit
fi
if ! clangd --version &> /dev/null ; then
    echo "install clangd"
    exit
fi
if ! tmux -V &> /dev/null ; then
    echo "install tmux"
    exit
fi
if ! nvim --version &> /dev/null ; then
    echo "install neovim"
    exit
fi

git submodule init
git submodule update

#
# zsh
#
ln -sfn $PWD/zshrc $HOME/.zshrc
ln -sfn $PWD/zprofile $HOME/.zprofile

#
# vim
#
ln -sfn "$PWD/nvim" "$HOME/.config/nvim"


#
# tmux
#
ln -sfn $PWD/tmux.conf $HOME/.tmux.conf
ln -sfn $PWD/tmux $HOME/.tmux
export TMUX_PLUGIN_MANAGER_PATH='$HOME/.tmux/plugins/'
~/.tmux/plugins/tpm/bin/install_plugins

# nvim +'PlugInstall --sync' +qa
# nvim +'PlugUpdate --sync' +qa
# nvim +'CocInstall coc-python' +qa
# nvim +'CocInstall coc-clangd' +qa

#cd ~/.tmux/plugins/tmux-thumbs
#cargo build --release
#cd -

#
# vscode
#
mkdir -p "$HOME/.config/Code - Insiders/User"
ln -sfn $PWD/vscode/settings.json "$HOME/.config/Code - Insiders/User"

mkdir -p "$HOME/.config/Code/User"
ln -sfn $PWD/vscode/settings.json "$HOME/.config/Code/User"


#
# other
#
ln -sfn $PWD/xdg/user-dirs.dirs "$HOME/.config/user-dirs.dirs"

#
# i3 and related
#

mkdir -p $HOME/.config/alacritty
ln -sfn $PWD/Xresources "$HOME/.Xresources"
ln -sfn $PWD/i3/config "$HOME/.config/i3/config"
ln -sfn $PWD/i3/i3status-rs.toml "$HOME/.config/i3/i3status-rs.toml"
ln -sfn $PWD/xprofile "$HOME/.xprofile"
ln -sfn $PWD/i3/picom.conf "$HOME/.config/picom.conf"
ln -sfn $PWD/alacritty.yml "$HOME/.config/alacritty/alacritty.yml"
ln -sfn $PWD/Preferences.sublime-settings "$HOME/.config/sublime-merge/Packages/User/Preferences.sublime-settings"

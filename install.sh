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
ln -sfn $PWD/vimrc $HOME/.vimrc
ln -sfn "$PWD/vim" "$HOME/.vim"
ln -sfn "$PWD/vim" "$HOME/.config/nvim"


#
# tmux
#
ln -sfn $PWD/tmux.conf $HOME/.tmux.conf
ln -sfn $PWD/tmux $HOME/.tmux
export TMUX_PLUGIN_MANAGER_PATH='$HOME/.tmux/plugins/'
~/.tmux/plugins/tpm/bin/install_plugins

nvim +'PlugInstall --sync' +qa
nvim +'PlugUpdate --sync' +qa
nvim +'CocInstall coc-python' +qa
nvim +'CocInstall coc-clangd' +qa

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

ln -sfn $PWD/Xresources "$HOME/.Xresources"
ln -sfn $PWD/i3/config "$HOME/.config/i3/config"
ln -sfn $PWD/i3/i3status-rs.toml "$HOME/.config/i3/i3status-rs.toml"

#./install-cargo-bins.sh

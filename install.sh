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
cd ~/.tmux/plugins/tmux-thumbs
cargo build --release
cd -

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

cargo install bat
cargo install exa
cargo install fd-find
cargo install tealdeer
cargo install skim
cargo install thumbs

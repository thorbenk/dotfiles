ln -sfn $PWD/vimrc $HOME/.vimrc
ln -sfn "$PWD/vim" "$HOME/.vim"
ln -sfn $PWD/vimrc $HOME/.nvimrc

ln -sfn $PWD/zshrc $HOME/.zshrc

ln -sfn $PWD/profile $HOME/.profile

mkdir -p "$HOME/.config/Code - Insiders/User"
ln -sfn $PWD/vscode/settings.json "$HOME/.config/Code - Insiders/User"

mkdir -p "$HOME/.config/Code/User"
ln -sfn $PWD/vscode/settings.json "$HOME/.config/Code/User"

ln -sfn $PWD/xdg/user-dirs.dirs "$HOME/.config/user-dirs.dirs"

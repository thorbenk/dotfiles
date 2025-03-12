#!/usr/bin/bash

set -e
#sudo apt install -y ninja-build gettext cmake unzip curl
#mkdir -p ~/code/3rdparty
cd ~/code/3rdparty
#git clone https://github.com/neovim/neovim
cd neovim
#make CMAKE_BUILD_TYPE=Release
cd build && cpack -G DEB && sudo dpkg -i nvim-linux-arm64.deb
#nvim -V1 -v

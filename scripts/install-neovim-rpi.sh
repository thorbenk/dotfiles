#/bin/bash
# see https://github.com/neovim/neovim/wiki/Building-Neovim

set -e

sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip

mkdir -p /tmp/build-nvim
cd /tmp/build-nvim
if [ -d "neovim" ]; then
    cd neovim
    git pull
    cd ..
else
    git clone https://github.com/neovim/neovim
fi
cd neovim
make CMAKE_BUILD_TYPE=Release
make CMAKE_INSTALL_PREFIX=$HOME/.local install

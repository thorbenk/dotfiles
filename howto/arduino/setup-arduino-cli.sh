#!/bin/bash

set -e

SCRIPT_DIR=$PWD

cd ~/.local/
if [ ! -f ~/.local/bin/arduino-cli ]; then
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
fi

PATH=~/.local:$PATH

cd $SCRIPT_DIR

if [ ! -f ~/.arduino15/arduino-cli.yaml  ]; then
  arduino-cli config init
fi
arduino-cli core update-index
arduino-cli core install arduino:avr
arduino-cli lib install "Adafruit NeoPixel"

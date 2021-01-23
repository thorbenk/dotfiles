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
arduino-cli lib install "LiquidCrystal"
arduino-cli lib install "Encoder"
arduino-cli lib install "FastLED"
arduino-cli lib install "WS2812FX"

# ESP32:
# Add this to ~/.arduino15/arduino-cli.yaml
#
#  board_manager:
#    additional_urls:
#      - https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json

arduino-cli core update-index
arduino-cli core install esp32:esp32

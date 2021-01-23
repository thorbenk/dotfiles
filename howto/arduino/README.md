## Notes on Arduino Development

First, setup `arduino-cli` as shown in `setup-arduino-cli.sh`.

## ESP32 board

```
# First, we needs a Python 2 environment:
virtualenv --python=python2 .venv
source .venv/bin/activate
pip install pyserial

# Can now compile and upload to board "ESP32-DevKitC V4"
arduino-cli compile --fqbn esp32:esp32:esp32
arduino-cli upload --fqbn esp32:esp32:esp32 --port /dev/ttyUSB0
```

## Arduino Nano

```
# Compile and upload to an "Arduino Nano" board
arduino-cli compile --fqbn arduino:avr:nano
arduino-cli upload --fqbn arduino:avr:nano:cpu=atmega328old --port /dev/ttyUSB0
```

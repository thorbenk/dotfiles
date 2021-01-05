#!/bin/bash

set -e

arduino-cli compile --fqbn arduino:avr:nano
arduino-cli upload --fqbn arduino:avr:nano:cpu=atmega328old --port /dev/ttyUSB0

# Debugging screen share issues with Google Chrome

```
PIPEWIRE_DEBUG=3 google-chrome --enable-features=WebRTCPipeWireCapturer,UseOzonePlatform --ozone-platform=wayland --enable-logging --log-level=0
```

Edit `~/.config/pipewire/pipewire.conf` and find the `default.clock.quantum` line, change it to:
```
default.clock.quantum = 512
default.clock.min-quantum = 32
default.clock.max-quantum = 1024
```

systemctl --user restart pipewire wireplumber


```bash
# Install Flatpak Chrome which bundles newer PipeWire runtime
sudo apt install flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install flathub com.google.Chrome

# Run Flatpak Chrome (has newer PipeWire support)
flatpak run com.google.Chrome
```

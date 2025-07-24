snap install zig --classic --beta

zig build -Doptimize=ReleaseFast -fno-sys=gtk4-layer-shell

./zig-out/bin/ghostty

(To show a window, either specify `./zig-out/bin/ghostty --launched-from=desktop` or set this option in the config below)

# Sample config

```
window-decoration = auto
launched-from = desktop
# keybind = global:alt+space=toggle_quick_terminal
```


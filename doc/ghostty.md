Download zig version [0.15.1](https://ziglang.org/download/0.15.2/zig-x86_64-linux-0.15.2.tar.xz)  and put in ``~/.local/bin`.

```bash
zig build -Doptimize=ReleaseFast -fno-sys=gtk4-layer-shell

./zig-out/bin/ghostty
```

When creating a `.desktop` entry, add `LD_LIBRARY_PATH=<build_dir>/zig-out/lib`.

# Sample config

```
window-decoration = client
mouse-scroll-multiplier=0.25
# keybind = global:alt+space=toggle_quick_terminal
```

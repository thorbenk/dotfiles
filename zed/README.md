# Notes for zed

## Compile

To compile both zed and the cli, run:

```bash
cargo build --release -p zed -p cli
```

Make sure the following are installed:

```bash
hash basedpyright 2>/dev/null || { echo >&2 "basedpyright required. Aborting."; exit 1; }
hash basedpyright-langserver 2>/dev/null || { echo >&2 "basedpyright-langserver required. Aborting."; exit 1; }
```

And to fixup the GPU:

```bash
# echo "Launching $ZED_BIN -- $@"

# __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia $ZED_BIN -- "$@"
# check `glxinfo | grep OpenGL` should show nvidia card

# DRI_PRIME=pci-0000_01_00_0 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia glxinfo | grep 'OpenGL renderer string'\

# RUST_LOG=info DRI_PRIME=pci-0000_01_00_0 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia poetry run $ZED_BIN -- -- --foreground "$@"

# RUST_LOG=info DRI_PRIME=pci-0000_01_00_0 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia $ZED_BIN -- --foreground "$@"
DRI_PRIME=pci-0000_01_00_0 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia $ZED_BIN "$@" &>/dev/null & disown
```


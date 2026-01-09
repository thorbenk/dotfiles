# nerd-dictation

## Setup `ydotool`

Following https://github.com/ideasman42/nerd-dictation/blob/main/readme-ydotool.rst

First, steup the udev rules correctly:

`/etc/udev/rules.d/99-input.rules`:
```
KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
```

Then verify `groups | grep input`.

```
systemctl --user daemon-reload
systemctl --user enable ydotoold.service
systemctl --user start ydotoold.service
```

nerd-dictation begin --simulate-input-tool=YDOTOOL

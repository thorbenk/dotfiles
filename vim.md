# Vim

Currently using some Alt-Shortcuts, which don't work within terminal
emulators, but only in gvim.

- Jump to previous: `C-o` ("old")

## Help

After reading (parts) of the manual, here are some notes:

- Jump to topic: `C-]`, back via `C-o`

## C++

```
set makeprg=ninja\ -C\ /bath/to/builddir
:make
```

## usr_20.txt

- Editing in command line
  - Jump to beginning `C-B`, end `C-E`
  - Delete word `C-W`
  - Erase everything `C-U`
- Cancel `C-C`
- Go through cmd line history: `C-P`, `C-N` (previous, next)
- open history via `q:` in normal mode, edit any line and `<Enter>` to
  execute

## usr_21.txt



## Vim command line

- insert
  - word under cursor `C-R C-W`, WORD `C-R C-A`
  - from register `C-R=` (unnamed register), `C-R%` (current filename),
    `C-R+` (X11 clipboard)

## FZF

- open `Space-F`
- search `Space-A` (Ag)
- history `Space-H`
- buffers `Space-B`

## Window Management

- Navigate around windows `A-{hjkl}`
- Resize windows with `A-S-{hjkl}`

## CtrlP

- ask which split to use `C-o` 

## NerdTree

- Open/close the tree `A-0`
- With a file selected in the tree, open it
  in horizontal split `i`, vertical split `s`,

## Navigation

- Jump back/forward `C-o`, `C-i`

## Folds

- Open/close `zo`, `zc` (`z` is a folded piece of paper)
- Close all `zm` ("fold more": decrease foldlevel)

## Rust

- `F1` runs `cargo build` in the background
- Quickfix window opens if errors occured  
  `:Copen` to manually open (e.g. to look at warnings)
- `:cf` jumps to first error, `:cn` to next

- `gd` goes to definition


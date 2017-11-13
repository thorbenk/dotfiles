# CLI

## FZF

- `** <TAB>` expand argument with fzf
- `Ctrl+T` search file and paste into command line
- `Alt+C` change dir
- `Ctrl+R` search history

## Misc

- List all dotfiles sorted by size
  ```
  ls -a1 | egrep '^\.' | xargs -n1 du -sh | sort -rh
  ```

# CLI

- List all dotfiles sorted by size
  ```
  ls -a1 | egrep '^\.' | xargs -n1 du -sh | sort -rh
  ```
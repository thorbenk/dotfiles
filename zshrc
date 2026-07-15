export NVIM="nvim"
export EDITOR=$NVIM
export VISUAL=$NVIM

# Deprecated as an nvim startup flag (nvim itself uses --listen / $NVIM now),
# but still honored by neovim-remote (nvr) et al., so kept for that tooling.
export NVIM_LISTEN_ADDRESS="/tmp/nvimsocket"

if [ `hostname` = "raspberrypi" ]; then
    # otherwise, command prompt is messed up?
    export LC_ALL="C"
fi

export NOBACKUP="/nobackup"
export LOCAL_INSTALL_PREFIX=/nobackup/inst
export KDEV_DUCHAIN_DIR=$NOBACKUP/kdevduchain

export DOTFILES_DIR=$HOME/code/dotfiles
ZSH_PLUGINS=$DOTFILES_DIR/zsh/plugins

# history file + sizes (were oh-my-zsh defaults; set explicitly now).
# dedup setopts live in the "extra settings" section below.
export HISTFILE=$HOME/.zsh/.zsh_history
export HISTSIZE=50000
export SAVEHIST=10000

#=== bare zsh (replaced oh-my-zsh) ===========================================
# A small setup we own: completion, keybindings, a minimal prompt, and the few
# oh-my-zsh conveniences actually used (ssh-agent, copypath, dotenv), plus the
# plugin submodules. zsh-syntax-highlighting is sourced at the END of this file
# so it wraps every ZLE widget defined here and later.

#--- completion --------------------------------------------------------------
# WORDCHARS='' => ^W and word-motions treat punctuation as boundaries, so ^W
# deletes one path component at a time. (This matches oh-my-zsh's default.)
WORDCHARS=''

autoload -Uz compinit
compinit -u -d "$HOME/.zsh/.zcompdump"    # -u: don't nag about the vendored dirs

zstyle ':completion:*' menu select                         # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/.zcompcache"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"    # color the matches
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'

#--- directory navigation ----------------------------------------------------
setopt AUTO_CD            # `foo/` means `cd foo/`
setopt AUTO_PUSHD         # cd pushes onto the dir stack (use `cd -<TAB>`)
setopt PUSHD_IGNORE_DUPS
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

#--- keybindings -------------------------------------------------------------
bindkey -e                              # emacs-style line editing
bindkey '^[[H'   beginning-of-line      # Home
bindkey '^[OH'   beginning-of-line
bindkey '^[[F'   end-of-line            # End
bindkey '^[OF'   end-of-line
bindkey '^[[3~'  delete-char            # Delete
bindkey '^[[1;5C' forward-word          # Ctrl-Right
bindkey '^[[1;5D' backward-word         # Ctrl-Left
# Up/Down search history by the prefix already typed.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

#--- ls / completion colors --------------------------------------------------
# oh-my-zsh used to populate LS_COLORS; do it ourselves so it survives.
if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
fi

#--- prompt (minimal: exit status, cwd, git branch) --------------------------
setopt PROMPT_SUBST
autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:git:*' formats       ' %F{magenta}%b%f'
zstyle ':vcs_info:git:*' actionformats ' %F{magenta}%b|%a%f'
add-zsh-hook precmd vcs_info
# %(?..) prints the exit code in red only when the last command failed.
PROMPT='%(?..%F{red}%? %f)%F{cyan}%~%f${vcs_info_msg_0_} %F{green}%#%f '

#--- ssh-agent ---------------------------------------------------------------
# Prefer an agent already provided (desktop/systemd). Otherwise start a
# persistent one and cache its env so all shells share a single agent.
if [ -z "$SSH_AUTH_SOCK" ]; then
    _ssh_env="$HOME/.zsh/.ssh-agent-env"
    [ -f "$_ssh_env" ] && source "$_ssh_env" >/dev/null
    ssh-add -l >/dev/null 2>&1
    if [ $? -eq 2 ]; then           # 2 => no reachable agent
        ssh-agent -s > "$_ssh_env"
        source "$_ssh_env" >/dev/null
    fi
    unset _ssh_env
fi

#--- copypath: copy the absolute path of a file/dir (default cwd) to clipboard
copypath() {
    local f="${1:-.}"; [[ $f = /* ]] || f="$PWD/$f"
    print -n -- "${f:A}" | wl-copy && echo "${f:A} copied to clipboard."
}

#--- terminal / (non-tmux) window title --------------------------------------
_title_precmd() { print -Pn "\e]2;%~\a" }
_title_preexec() { print -Pn "\e]2;$1\a" }
add-zsh-hook precmd  _title_precmd
add-zsh-hook preexec _title_preexec

#--- plugins (zsh-syntax-highlighting is sourced at the END of this file) -----
source $ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH_PLUGINS/zsh-you-should-use/you-should-use.plugin.zsh

#--- zsh copybuffer plugin ---------------------------------------------------

# copybuffer: adds the ctrl-o keyboard shortcut to copy the current text in
#             the command line to the system clipboard.
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/copybuffer/copybuffer.plugin.zsh
copybuffer () {
  printf "%s" "$BUFFER" | wl-copy
}
zle -N copybuffer
bindkey -M emacs "^O" copybuffer
bindkey -M viins "^O" copybuffer
bindkey -M vicmd "^O" copybuffer

#--- zsh extra settings ------------------------------------------------------

setopt NO_SHARE_HISTORY
setopt INC_APPEND_HISTORY  # write each command immediately (crash-safe), without live-sharing into other sessions

# history dedup (HISTSIZE/SAVEHIST set near the top)
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

#unsetopt auto_name_dirs #do not replace path with environment variables

#http://en.gentoo-wiki.com/wiki/Zsh
# autoload -U compinit
# compinit
# zstyle ':completion::complete:*' use-cache 1

#http://blog.wannawork.de/2009/11/10/mit-mac-per-ssh-auf-debian-zsh-backspace-reparieren/
# bindkey '^?' backward-delete-char
# bindkey '^[[3~' delete-char

#http://yountlabs.com/automation/disable-autocorrect-in-zsh/
unsetopt correct_all

# bindkey "^[[1;5C" forward-word # ctrl + left
# bindkey "^[[1;5D" backward-word # ctrl + right
# # bindkey "\e[H" beginning-of-line # home
# # bindkey "\e[F" end-of-line # end
# bindkey "^[OF" beginning-of-line # home
# bindkey "~[OH" end-of-line # end


#--- fzf ------------------------------------------------------------------

# use ripgrep to hide ignored files
export FZF_DEFAULT_COMMAND="rg --files"

#--- git worktree picker -----------------------------------------------------

# wt: fuzzy-pick a git worktree and cd into it.
#   - lists every worktree as "<branch>  <path>"; type to filter
#   - Enter cd's into the selected worktree
#   - preview pane shows that worktree's recent commits
# (named 'wt' so it doesn't clash with oh-my-zsh's `gwt`=`git worktree`)
wt () {
  emulate -L zsh
  command git rev-parse --git-dir >/dev/null 2>&1 || {
    echo "wt: not inside a git repository" >&2
    return 1
  }

  local selection dir
  selection=$(
    command git worktree list --porcelain | awk '
      /^worktree /  { path = substr($0, 10) }
      /^branch /    { ref = substr($0, 8); sub(/^refs\/heads\//, "", ref); emit() }
      /^detached$/  { ref = "(detached)"; emit() }
      /^bare$/      { ref = "(bare)"; emit() }
      function emit() {
        disp = path
        sub("^" ENVIRON["HOME"], "~", disp)
        printf "%-30s %s\t%s\n", ref, disp, path
        ref=""; path=""
      }
    ' | fzf --delimiter='\t' --with-nth=1 \
            --prompt='worktree> ' \
            --height=40% --reverse --ansi \
            --preview='git -C {2} -c color.ui=always log --oneline -15' \
            --preview-window='right:55%'
  ) || return

  dir=${selection##*$'\t'}
  [[ -n $dir && -d $dir ]] && cd -- "$dir"
}

#--- alias ------------------------------------------------------------------

alias "vim=$NVIM"
alias 'ls=ls --color=auto'
alias 'll=ls -lh --color=auto'
alias 'grep=grep --colour'
alias 'f=fzf'

# rm safety: -I prompts once before a recursive delete or removing >3 files
# (unlike -i, which nags per file). Scripts call /bin/rm directly, so unaffected.
alias 'rm=rm -I'

# Automatically background processes (no output to terminal etc)
alias 'z=echo $RANDOM > /dev/null; zz'
zz () {
    echo "$@"
    "$@" &> "/tmp/z-$1-$RANDOM" &!
}

# Aliases to use this; use e.g. 'command gv' to avoid
for i in acroread chromium eclipse \
         gimp k3b \
         kopete kwrite kate konqueror dolphin gwenview okular amarok akregator \
         kile \
         localc lowriter lodraw \
         firefox thunderbird; do
    alias "$i=z $i"
done

alias inkscape="GDK_SCALE=2 GDK_DPI_SCALE=0.5 /usr/bin/inkscape"

alias plssh="ssh-add ~/.ssh/id_rsa"

#--- paths ------------------------------------------------------------------

export PATH=$DOTFILES_DIR/bin:$PATH

[ -f ~/.zshrc.user ] && source ~/.zshrc.user

export PATH="$HOME/.local/bin:$PATH"

# fzf: modern integration. `fzf --zsh` (fzf >= 0.48) emits key-bindings +
# completion in sync with the binary, replacing the old source-the-shipped-
# scripts dance. fzf is pinned in install.lock.json and installed to ~/.local/bin
# (hence after the PATH export above).
#
# The `[[ -t 0 ]]` guard: fzf's key-bindings are ZLE widgets, useful only with a
# terminal on stdin. It also silences fzf's harmless "can't change option: zle"
# warning in TTY-less interactive shells (e.g. `zsh -ic exit`): fzf's internal
# `emulate zsh` flips zle off, then its option-restore can't turn it back on
# without a tty. Real terminals (tty=yes) load fzf normally and never warn.
if command -v fzf >/dev/null 2>&1 && [[ -t 0 ]]; then
    source <(fzf --zsh)
fi

export GCM_CREDENTIAL_STORE="secretservice"

if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# zed: launch detached on the NVIDIA GPU, then hand the shell back.
#   VK_DRIVER_FILES pins the Vulkan loader to the RTX 2000 (swap to
#   intel_icd.json for the Intel iGPU). We run the `zed` binary directly and
#   background+disown it with `&!`
#   The recurring "crashes" were the OOM killer reaping the session during big
#   parallel C++ builds (62G RAM, ~2G swap). zed-oom-protect lowers Zed's
#   oom_score_adj so the build dies first; it needs the one-time root install
#   (see zed/zed-oom-protect) and silently no-ops if not installed.
zed () {
    env VK_DRIVER_FILES=/usr/share/vulkan/icd.d/nvidia_icd.json \
        /x/3rdparty/zed/target/release-fast/zed "$@" &>/dev/null &!
    ( sudo -n /usr/local/sbin/zed-oom-protect & ) >/dev/null 2>&1
}

# --use-on-cd auto-switches node version when entering a dir with a
# .nvmrc/.node-version. fnm is pinned in install.lock.json; node itself is
# managed by fnm (fnm install/default).
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --use-on-cd --shell zsh)"
fi

#--- direnv: per-directory env (.envrc / .env) -------------------------------
# Replaces oh-my-zsh's dotenv plugin. Loads a dir only after `direnv allow`, so
# no auto-run RCE. `load_dotenv=true` in ~/.config/direnv/direnv.toml keeps the
# old `.env` behavior. After the ~/.local/bin PATH export so direnv is found.
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

#--- atuin: SQLite shell history + search ------------------------------------
# Rebinds Ctrl-R to atuin's fuzzy full-history search (its own SQLite DB, synced
# across sessions/machines). --disable-up-arrow keeps the Up key on the existing
# prefix search (up-line-or-beginning-search, bound above); zsh's own HISTFILE
# still backs that, so both coexist. atuin is pinned in install.lock.json and
# installed to ~/.local/bin (hence after the PATH export above). Before
# syntax-highlighting since it defines ZLE widgets.
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh --disable-up-arrow)"
fi

#--- zoxide: frecency-based cd -----------------------------------------------
# --cmd cd replaces `cd`: plain `cd path` still works, but `cd foo` also jumps
# to the highest-frecency dir matching "foo", and `cdi` opens an interactive
# picker (uses fzf, already installed). The default command name `z` is left
# alone because this zshrc already uses `z` as a backgrounding helper (see the
# GUI-app aliases above). zoxide is pinned in install.lock.json and installed to
# ~/.local/bin (hence after the PATH export above).
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd cd)"
fi

#--- zsh-syntax-highlighting (MUST be last) ----------------------------------
# It wraps every ZLE widget defined so far, so it has to come after all other
# widget setup (copybuffer, fzf, fnm, etc.).
source $ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

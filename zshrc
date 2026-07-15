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
export ZSH_CUSTOM=$DOTFILES_DIR/zsh

# history (HISTFILE set before oh-my-zsh, which only sets it if unset;
# dedup setopts are applied after the source in the extra-settings section)
export HISTFILE=$HOME/.zsh/.zsh_history

#--- oh-my-zsh ---------------------------------------------------------------

export ZSH=$DOTFILES_DIR/oh-my-zsh
export ZSH_THEME="half-life"
# export CASE_SENSITIVE="false" # case-insensitive completion
# export DISABLE_AUTO_UPDATE="true" # no weekly update checks

# zsh-syntax-highlighting must be last so it wraps all other ZLE widgets.
plugins=(git ssh-agent copypath dotenv zsh-autosuggestions zsh-you-should-use zsh-syntax-highlighting)
# colored-man-pages zsh-bat
source $ZSH/oh-my-zsh.sh

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

# history dedup (HISTSIZE/SAVEHIST left at oh-my-zsh defaults: 50000/10000)
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

if [ -f /usr/share/fzf/key-bindings.zsh ]; then
    # fzf install in Manjaro
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh
elif [ -f ~/.fzf.zsh ]; then
    # fzf local user install
    source ~/.fzf.zsh
    export PATH=$HOME/.fzf/bin:$PATH
fi

export PATH="$HOME/.local/bin:$PATH"

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

# eval "$(starship init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

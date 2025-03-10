if [ -f /usr/share/fzf/key-bindings.zsh ]; then
  # NVIM="/opt/nvim/nvim.appimage"
  NVIM="nvim"
else
  NVIM="nvim"
fi

export EDITOR=$NVIM
export VISUAL=$NVIM

export NVIM_LISTEN_ADDRESS="/tmp/nvimsocket"

if [ `hostname` = "raspberrypi" ]; then
    # otherwise, command prompt is messed up?
    export LC_ALL="C"
fi

export NOBACKUP="/nobackup"
export LOCAL_INSTALL_PREFIX=/nobackup/inst
export KDEV_DUCHAIN_DIR=$NOBACKUP/kdevduchain

export DOTFILES_DIR=$HOME/code/dotfiles
export ZSH=$HOME/.zsh
export ZSH_CUSTOM=$DOTFILES_DIR/zsh

# history
export HISTFILE=$HOME/.zsh/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

#--- oh-my-zsh ---------------------------------------------------------------

export ZSH=$DOTFILES_DIR/oh-my-zsh
export ZSH_THEME="half-life"
# export CASE_SENSITIVE="false" # case-insensitive completion
# export DISABLE_AUTO_UPDATE="true" # no weekly update checks

plugins=(git ssh-agent copypath dotenv zsh-autosuggestions zsh-syntax-highlighting zsh-you-should-use)
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

#--- alias ------------------------------------------------------------------

alias "vim=$NVIM"
alias 'ls=ls --color=auto'
alias 'll=ls -lh --color=auto'
alias 'grep=grep --colour'
alias 'f=fzf'

# Automatically background processes (no output to terminal etc)
alias 'z=echo $RANDOM > /dev/null; zz'
zz () {
    echo $*
    $* &> "/tmp/z-$1-$RANDOM" &!
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

alias plssh="z ssh-add ~/.ssh/id_rsa"

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

alias zed="env DRI_PRIME=pci-0000_01_00_0 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia /w/src/3rdparty/zed/target/release/cli"

# eval "$(starship init zsh)"

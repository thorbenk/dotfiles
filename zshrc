export EDITOR="nvim"
export VISUAL="nvim"

export NVIM_LISTEN_ADDRESS="/tmp/nvimsocket"

if [ `hostname` = "raspberrypi" ]; then
    # otherwise, command prompt is messed up?
    export LC_ALL="C"
fi

export NOBACKUP="/nobackup"
export LOCAL_INSTALL_PREFIX=/nobackup/inst
export KDEV_DUCHAIN_DIR=$NOBACKUP/kdevduchain

#--- oh-my-zsh ---------------------------------------------------------------

export DOTFILES_DIR=$HOME/code/dotfiles
export ZSH=$DOTFILES_DIR/oh-my-zsh
export ZSH_THEME="half-life"
export CASE_SENSITIVE="false" # case-insesitive completion
export DISABLE_AUTO_UPDATE="true" # no weekly update checks
plugins=(git svn colored-man-pages ssh-agent zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

#--- zsh --------------------------------------------------------------------

#unsetopt auto_name_dirs #do not replace path with environment variables

#http://en.gentoo-wiki.com/wiki/Zsh
autoload -U compinit
compinit
zstyle ':completion::complete:*' use-cache 1

#http://blog.wannawork.de/2009/11/10/mit-mac-per-ssh-auf-debian-zsh-backspace-reparieren/
bindkey '^?' backward-delete-char
bindkey '^[[3~' delete-char

#http://yountlabs.com/automation/disable-autocorrect-in-zsh/
unsetopt correct_all

# setopt NO_SHARE_HISTORY

#--- fzf ------------------------------------------------------------------

# use ripgrep to hide ignored files
export FZF_DEFAULT_COMMAND="rg --files"

#--- alias ------------------------------------------------------------------

# http://matt.blissett.me.uk/linux/zsh/zshrc

alias 'vim=nvim'
alias 'l=ls'
alias 'll=ls -lh'
alias 'kw=kwrite'
alias 'tf=tail -f'
alias 'grep=grep --colour'
alias 'creator=QT_PLUGIN_PATH="" XDG_DATA_DIRS="" QML2_IMPORT_PATH="" QT_PLUGIN_PATH="" XDG_DATA_DIRS="" /nobackup/thirdparty/qt-creator/bin/qtcreator.sh'
alias 'qtc=QT_PLUGIN_PATH="" XDG_DATA_DIRS="" QML2_IMPORT_PATH="" QT_PLUGIN_PATH="" XDG_DATA_DIRS="" /nobackup/thirdparty/qtc-master/bin/qtcreator.sh'
alias 'f=fzf'
alias 'k=z kate'

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

#important: in PATH, we have a 'make' scripts with call 'objmake'
#so we can make with srcdir != builddir
#http://blogs.kde.org/node/2559

# export PATH=$LOCAL_INSTALL_PREFIX/bin:$PATH
# export PYTHONPATH="$LOCAL_INSTALL_PREFIX/lib/python/site-packages:$PYTHONPATH"
# export CMAKE_INSTALL_LOCAL_INSTALL_PREFIX="$LOCAL_INSTALL_PREFIX"
# export CMAKE_INCLUDE_PATH="$LOCAL_INSTALL_PREFIX/include"
# export CMAKE_LIBRARY_PATH="$LOCAL_INSTALL_PREFIX/lib"
# export CMAKE_LOCAL_INSTALL_PREFIX_PATH="$LOCAL_INSTALL_PREFIX"

#export PYTHONPATH=$DOTFILES_DIR/pytk:$PYTHONPATH
export PATH=/opt/bin:$HOME/.cargo/bin:$DOTFILES_DIR/bin:$PATH

[ -f ~/.zshrc.user ] && source ~/.zshrc.user

if [ -f /usr/share/fzf/key-bindings.zsh ]; then
    # fzf install in Manjaro
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh
elif [ -f ~/.fzf.zsh ]; then
    # fzf local user install 
    source ~/.fzf.zsh
fi

export PATH="$HOME/.local/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

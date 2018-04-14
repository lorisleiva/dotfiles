# Global options
export DOTFILES=$HOME/🔥/dotfiles
export ZSH=$HOME/.oh-my-zsh
export EDITOR=subl

# Oh my zsh configurations.
ZSH_THEME="cloud"
ZSH_CUSTOM=$DOTFILES
unsetopt nomatch
plugins=()
source $ZSH/oh-my-zsh.sh

# Autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh
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

# Nvm
export NVM_DIR="$HOME/.nvm"
[ -f /usr/local/opt/nvm/nvm.sh ] && . /usr/local/opt/nvm/nvm.sh
[ -f /usr/local/share/bash-completion/bash_completion ] && . /usr/local/share/bash-completion/bash_completion

# iTerm shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
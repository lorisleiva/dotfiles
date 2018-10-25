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
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# iTerm shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
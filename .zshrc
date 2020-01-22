# Global options
export DOTFILES=$HOME/🔥/dotfiles
export ZSH=$HOME/.oh-my-zsh
export EDITOR=subl
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault-password

# Oh my zsh configurations.
ZSH_THEME="cloud"
ZSH_CUSTOM=$DOTFILES
unsetopt nomatch
plugins=()
source $ZSH/oh-my-zsh.sh

# Autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# iTerm shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
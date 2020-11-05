# Global options
export DOTFILES=$HOME/Code/dotfiles
export ZSH=$HOME/.oh-my-zsh
export EDITOR=code
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault-password

# Oh my zsh configurations.
ZSH_THEME=""
ZSH_CUSTOM=$DOTFILES/zsh
unsetopt nomatch
plugins=(zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# iTerm shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# The Fuck binary
eval $(thefuck --alias)
eval "$(gh completion -s zsh)"

# https://github.com/sindresorhus/pure
autoload -U promptinit; promptinit
prompt pure

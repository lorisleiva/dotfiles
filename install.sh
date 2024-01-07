#!/bin/sh

# ------------------------------------------------------------------------------
#  Configurations.
# ------------------------------------------------------------------------------

DOTFILES=$HOME/Code/dotfiles

echo "Setting up your Mac..."

# ------------------------------------------------------------------------------
#  Install Brew and its dependencies.
# ------------------------------------------------------------------------------

if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update
brew tap homebrew/bundle
brew bundle

# ------------------------------------------------------------------------------
#  GPG Agent. Avoid having to enter the paraphrase all the time.
# ------------------------------------------------------------------------------

echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >>~/.gnupg/gpg-agent.conf
killall gpg-agent

# ------------------------------------------------------------------------------
#  Install PECL extensions.
# ------------------------------------------------------------------------------

sudo pecl install imagick xdebug

# ------------------------------------------------------------------------------
#  Global shell configurations.
# ------------------------------------------------------------------------------

# Prepare NVM config folder.
mkdir -p ~/.nvm

# Use global .gitignore file.
git config --global core.excludesfile $DOTFILES/.gitignore_global

# Use zsh as default shell.
chsh -s $(which zsh)

# Link .zshrc file.
touch ~/.zshrc
echo "source \$HOME/Code/dotfiles/zsh/.zshrc" > ~/.zshrc

# Install Oh My Zsh.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# ------------------------------------------------------------------------------
#  Install Composer dependencies.
# ------------------------------------------------------------------------------

composer global require laravel/valet
valet install

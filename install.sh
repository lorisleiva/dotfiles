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
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew update
brew tap homebrew/bundle
brew bundle

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

# ------------------------------------------------------------------------------
#  Install Composer dependencies.
# ------------------------------------------------------------------------------

composer global install
valet install

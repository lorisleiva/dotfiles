#!/bin/sh

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

sudo pecl install imagick

# ------------------------------------------------------------------------------
#  Install Composer dependencies.
# ------------------------------------------------------------------------------

composer global install
valet install

# ------------------------------------------------------------------------------
#  Use zsh as default shell
# ------------------------------------------------------------------------------

chsh -s $(which zsh)
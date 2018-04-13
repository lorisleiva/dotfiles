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

# ------------------------------------------------------------------------------
#  Make ZSH the default shell environment.
# ------------------------------------------------------------------------------

chsh -s $(which zsh)

# ------------------------------------------------------------------------------
#  Install Composer dependencies.
# ------------------------------------------------------------------------------

composer global require laravel/installer laravel/valet
valet install

# ------------------------------------------------------------------------------
#  Create a project directory.
# ------------------------------------------------------------------------------

mkdir -p $HOME/🔥
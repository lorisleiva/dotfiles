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
#  Install Composer and its dependencies.
# ------------------------------------------------------------------------------

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

composer global require laravel/installer laravel/valet
valet install

# ------------------------------------------------------------------------------
#  Install global NPM packages.
# ------------------------------------------------------------------------------

npm install --global yarn

# ------------------------------------------------------------------------------
#  Create a project directory.
# ------------------------------------------------------------------------------

mkdir -p $HOME/🔥
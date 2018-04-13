#!/bin/sh

echo "Setting up your Mac..."

# Path to dotfiles folder
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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
#  Install Composer dependencies.
# ------------------------------------------------------------------------------

composer global require laravel/installer laravel/lumen-installer laravel/valet
valet install

# ------------------------------------------------------------------------------
#  Restore configurations
# ------------------------------------------------------------------------------

chsh -s $(which zsh)
cp "$DIR/.mackup.cfg" "$HOME/.mackup.cfg"
echo "# Load Zsh\nsource $DIR/.zshrc" > "$HOME/.zshrc"

# ------------------------------------------------------------------------------
#  Create a project directory.
# ------------------------------------------------------------------------------

mkdir -p $HOME/🔥
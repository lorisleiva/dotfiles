#!/usr/bin/env bash
# Takes a fresh Mac from nothing to a built nix-darwin config.
# Usage: ./bootstrap.sh <profile>   (a darwinConfigurations name in flake.nix: personal, agents)
# Run this once. After it finishes, use ./rebuild.sh for every later change.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROFILE="${1:-}"
PROFILE_FILE="$HOME/.config/dotfiles/profile"

if [ -z "$PROFILE" ]; then
  echo "Usage: ./bootstrap.sh <profile>   (e.g. personal, agents)"
  exit 1
fi

echo "==> Step 1: Determinate Nix"
if command -v nix >/dev/null 2>&1; then
  echo "    nix already installed, skipping"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> Step 2: check the \"$PROFILE\" profile is for this account"
# Each profile names its macOS account in flake.nix; nothing here edits the repo.
PROFILE_USER="$(nix eval --raw "path:$DIR#darwinConfigurations.$PROFILE.config.system.primaryUser")"
if [ "$PROFILE_USER" != "$(whoami)" ]; then
  echo "    The \"$PROFILE\" profile is for the \"$PROFILE_USER\" account, but you are \"$(whoami)\"."
  echo "    Run it from that account, or add a profile for this one in flake.nix."
  exit 1
fi

echo "==> Step 3: symlink this repo to ~/.dotfiles and remember the profile"
ln -sfn "$DIR" ~/.dotfiles
mkdir -p "$(dirname "$PROFILE_FILE")"
echo "$PROFILE" > "$PROFILE_FILE"

echo "==> Step 4: first darwin-rebuild switch"
NIX_BIN="$(command -v nix)"
sudo "$NIX_BIN" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake "$HOME/.dotfiles#$PROFILE"

if [ "$PROFILE" = "personal" ]; then
  echo "==> Step 5: PHP extras (Homebrew PHP now exists after the switch)"
  # These have no clean Nix equivalent while PHP stays on Homebrew.
  if command -v pecl >/dev/null 2>&1; then
    sudo pecl install imagick xdebug || echo "    pecl step skipped/failed, run manually if needed"
  fi
  if command -v composer >/dev/null 2>&1; then
    composer global require laravel/valet
    valet install
  fi
fi

echo "==> Done. Use ./rebuild.sh for future changes."

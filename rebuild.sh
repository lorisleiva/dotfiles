#!/usr/bin/env bash
# Applies the config to this machine.
# Usage: ./rebuild.sh [profile]   (the profile bootstrap.sh used is remembered;
# pass one to set or change it, e.g. `./rebuild.sh personal` the first time).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROFILE_FILE="$HOME/.config/dotfiles/profile"

if [ -n "${1:-}" ]; then
  PROFILE="$1"
  mkdir -p "$(dirname "$PROFILE_FILE")"
  echo "$PROFILE" > "$PROFILE_FILE"
elif [ -f "$PROFILE_FILE" ]; then
  PROFILE="$(cat "$PROFILE_FILE")"
else
  echo "No profile remembered for this machine. Run once with one: ./rebuild.sh <profile> (e.g. personal, agents)"
  exit 1
fi

ln -sfn "$DIR" ~/.dotfiles
exec sudo darwin-rebuild switch --flake "$HOME/.dotfiles#$PROFILE"

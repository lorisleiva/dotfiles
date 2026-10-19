# Dotfiles

❄️ Personal set of configurations for macOS, powered by [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [Home Manager](https://github.com/nix-community/home-manager).

## Profiles

Each machine runs one profile: the shared modules (`modules/`) plus a profile on top (`profiles/`), declared in `flake.nix` with the macOS account it is for.

| Profile | Account | What it is |
|---|---|---|
| `personal` | `loris` | My everyday Mac: dev tools, apps, the PHP/web stack, commits signed with GPG. |
| `agents` | `paseo` | A dedicated machine for coding agents: dev tools only, no personal apps or keys, commits signed with the machine's own SSH key. |

To use these on your own machine, change the account names in `flake.nix` (or add a profile of your own).

## Fresh machine

1. Git clone to `~/Code/dotfiles`
2. Make sure the config fits your needs (`flake.nix`, `modules/`, `profiles/`)
3. Run `./bootstrap.sh <profile>`, e.g. `./bootstrap.sh personal`

## Everyday changes

Run `./rebuild.sh` after editing any config. It uses the profile `bootstrap.sh` was run with (kept in `~/.config/dotfiles/profile`); pass a profile name to set or change it.

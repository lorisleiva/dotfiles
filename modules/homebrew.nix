# Homebrew, and what every machine gets from it. A profile adds its own
# taps, brews and casks on top (the lists are merged).
{ user, ... }:

{
  nix-homebrew = {
    enable = true;
    inherit user;
  };

  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      # Anything installed but not declared by the machine's profile is removed.
      cleanup = "zap";
    };

    taps = [
      "anomalyco/tap"
    ];

    brews = [
      "autojump"
      "bash"
      "composer"
      "mysql"
      "neovim"
      "nvm"
      "php"
      "pnpm"
      "pure"
      {
        name = "redis";
        restart_service = "changed";
      }
      "tmux"
      "xcodegen"
      # tapped formulae (full paths)
      "anomalyco/tap/opencode"
    ];

    casks = [
      "claude-code@latest"
      "codex"
      "paseo"
      "wezterm"
    ];

    # NOTE: Mac App Store apps are intentionally not declared here.
    #
    # With `cleanup = "zap"`, nix-darwin runs `brew bundle --zap --force-cleanup`,
    # which unconditionally uninstalls any installed mas app not listed in the
    # Brewfile. The opt-outs (`HOMEBREW_BUNDLE_CLEANUP_NO_MAS` / `--no-cleanup-mas`)
    # are ignored on this `install --force-cleanup` code path (Homebrew/brew#22450),
    # so declaring some apps would force cleanup to remove the rest, including
    # SIP-protected/system apps like Xcode and TestFlight (which error out).
    #
    # Homebrew Bundle skips mas cleanup entirely when the Brewfile contains zero
    # mas entries, so we manage App Store apps manually instead. They auto-update
    # themselves. Apps previously declared here: Bear (1091189122),
    # Brother P-touch Editor (1453365242), Dynamic wallpaper (1582358382),
    # Image Vectorizer (789656124), Spark Desktop (6445813049), Things (904280696).
  };
}

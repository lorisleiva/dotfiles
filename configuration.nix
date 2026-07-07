{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };

  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "clmv";
  };

  nix-homebrew = {
    enable = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      cleanup = "zap";
    };

    taps = [
      "anomalyco/tap"
      "blendle/blendle"
      "shivammathur/php"
      "withgraphite/tap"
    ];

    brews = [
      "autojump"
      "bash"
      "cloudflared"
      "composer"
      "dnsmasq"
      "flock"
      "gh"
      "gnupg"
      "imagemagick"
      "mas"
      "mysql"
      "neovim"
      "nginx"
      "nvm"
      "openssl@3"
      "php"
      "php-code-sniffer"
      "php@8.1"
      "php@8.2"
      "pidof"
      "pinentry-mac"
      "pipx"
      "pnpm"
      "pure"
      "pyenv"
      "python@3.12"
      "rabbitmq"
      { name = "redis"; restart_service = "changed"; }
      "sqlite"
      "tmux"
      "yarn"
      # tapped formulae (full paths)
      "anomalyco/tap/opencode"
      "shivammathur/php/php@8.0"
      "withgraphite/tap/graphite"
    ];

    casks = [
      "anylist"
      "arc"
      "bartender"
      "chatgpt"
      "claude"
      "claude-code"
      "cleanshot"
      "daisydisk"
      "dbngin"
      "discord"
      "docker-desktop"
      "elgato-control-center"
      "figma"
      "firefox"
      "flux-app"
      "github"
      "google-chrome"
      "gpg-suite"
      "imageoptim"
      "insomnia"
      "iterm2"
      "jetbrains-toolbox"
      "mactex"
      "moom"
      "ngrok"
      "notion"
      "raycast"
      "signal"
      "sip-app"
      "slack"
      "spotify"
      "sublime-text"
      "tableplus"
      "telegram"
      "visual-studio-code"
      "vlc"
      "wezterm"
      "whatsapp"
    ];

    masApps = {
      "Bear" = 1091189122;
      "Brother P-touch Editor" = 1453365242;
      "Dynamic wallpaper" = 1582358382;
      "Image Vectorizer" = 789656124;
      "Spark Desktop" = 6445813049;
      "Things" = 904280696;
    };
  };
}

# My everyday Mac: everything in the shared modules, plus the apps I use day
# to day, the PHP/web stack for local sites, herdr, and GPG commit signing.
{ user, ... }:

{
  homebrew = {
    taps = [
      "blendle/blendle"
      "shivammathur/php"
      "withgraphite/tap"
    ];

    brews = [
      "cloudflared"
      "dnsmasq"
      "flock"
      "herdr"
      "mas"
      "nginx"
      "openssl@3"
      "php-code-sniffer"
      "php@8.1"
      "php@8.2"
      "pidof"
      "pinentry-mac"
      "pipx"
      "pyenv"
      "python@3.12"
      "rabbitmq"
      "yarn"
      # tapped formulae (full paths)
      "shivammathur/php/php@8.0"
      "withgraphite/tap/graphite"
    ];

    casks = [
      "anylist"
      "arc"
      "bartender"
      "chatgpt"
      "claude"
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
      "handy"
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
      "whatsapp"
    ];
  };

  home-manager.users.${user} =
    { config, pkgs, ... }:
    let
      dotfiles = "${config.home.homeDirectory}/.dotfiles";
    in
    {
      imports = [ ../herdr-plus.nix ];

      home.packages = with pkgs; [
        doctl
        gifski
        graphviz
        imagemagick
      ];

      home.sessionVariables.EDITOR = "code";

      programs.git.settings.user.signingkey = "6A6BFEB7EC92C347";

      home.file.".gnupg/gpg-agent.conf".text = ''
        default-cache-ttl 600
        max-cache-ttl 7200
        pinentry-program /opt/homebrew/bin/pinentry-mac
      '';

      home.file.".config/herdr".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
    };
}

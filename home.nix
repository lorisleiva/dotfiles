{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    ack
    bat
    coreutils
    dasel
    difftastic
    doctl
    findutils
    gifski
    gnutar
    gnugrep
    graphviz
    httpie
    jq
    prettyping
    tldr
    tree
    watch
    wget
  ];
  fonts.fontconfig.enable = true;

  # Programs.
  programs.fzf.enable = true;
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "Loris Leiva";
        email = "loris.leiva@gmail.com";
        signingkey = "6A6BFEB7EC92C347";
      };
      commit.gpgsign = true;
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      diff = {
        external = "difft";
        renames = "copies";
      };
      credential."https://github.com".helper = [ "" "!/opt/homebrew/bin/gh auth git-credential" ];
      credential."https://gist.github.com".helper = [ "" "!/opt/homebrew/bin/gh auth git-credential" ];
    };
    ignores = [
      ".DS_Store" ".DS_Store?" "._*" ".Spotlight-V100" ".Trashes"
      "ehthumbs.db" "Thumbs.db"
      ".idea/" ".vscode" ".nova/"
    ];
  };
  # programs.starship = {
  #   enable = true;
  #   settings = {
  #     add_newline = false;
  #     format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
  #     character = {
  #       success_symbol = "[❯](purple)";
  #       error_symbol = "[❯](red)";
  #     };
  #     cmd_duration.format = "[$duration]($style) ";
  #   };
  # };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      custom = "${dotfiles}/zsh";
      plugins = [ ];  # the two you had are now handled above
    };
    initContent = ''
      # env
      export DOTFILES="${dotfiles}"
      export EDITOR=code
      export DO_NOT_TRACK=1
      export CPATH="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"

      unsetopt nomatch

      # autojump (still on brew)
      [ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

      # iTerm shell integration
      test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"

      # gh completion
      eval "$(gh completion -s zsh)"

      # nvm (still on brew)
      export NVM_DIR="$HOME/.nvm"
      [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . "$(brew --prefix)/opt/nvm/nvm.sh"
      [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && . "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"

      # fzf
      source <(fzf --zsh)

      # pure prompt (still on brew)
      autoload -U promptinit; promptinit; prompt pure
    '';
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
    default-cache-ttl 600
    max-cache-ttl 7200
    pinentry-program /opt/homebrew/bin/pinentry-mac
  '';

  # Symlinks to dotfiles.
  home.file.".config/wezterm".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  # home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  # home.file.".config/herdr".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";

  home.file.".claude/CLAUDE.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.claude/settings.json";
  home.file.".claude/commands".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.claude/commands";
  home.file.".codex/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
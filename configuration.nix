{ user, ... }:

{
  imports = [ ./homebrew.nix ];

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
    finder.FXPreferredViewStyle = "clmv";
  };
}

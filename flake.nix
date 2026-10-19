{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nix-homebrew,
      home-manager,
      nixpkgs,
    }:
    let
      # One machine setup: the shared modules plus a profile on top.
      # `user` is the macOS account the setup is for; bootstrap.sh checks it.
      mkHost =
        { user, profile }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit user; };
          modules = [
            ./modules/darwin.nix
            ./modules/homebrew.nix
            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit user; };
              home-manager.users.${user} = import ./modules/home.nix;
              home-manager.backupFileExtension = "backup";
            }
            profile
          ];
        };
    in
    {
      # My everyday Mac: the full set of apps and tools.
      darwinConfigurations.personal = mkHost {
        user = "loris";
        profile = ./profiles/personal.nix;
      };

      # A dedicated machine for coding agents: the dev tools only, no personal
      # apps, and commits signed with that machine's own SSH key.
      darwinConfigurations.agents = mkHost {
        user = "paseo";
        profile = ./profiles/agents.nix;
      };
    };
}

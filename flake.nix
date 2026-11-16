{
  description = "Lewis's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }:
  let
    # Terraform's licence counts as "unfree" in Nix, so allow just that one.
    unfree = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "terraform" ];
  in
  {
    # Mac: apps through Homebrew casks, everything else through home.nix.
    darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
      modules = [
        home-manager.darwinModules.home-manager
        {
          nix.enable = false; # the Determinate installer manages Nix itself
          nixpkgs.hostPlatform = "aarch64-darwin";
          nixpkgs.config.allowUnfreePredicate = unfree;
          system.stateVersion = 6;
          system.primaryUser = "lewis.blackburn";
          users.users."lewis.blackburn".home = "/Users/lewis.blackburn";
          programs.zsh.enableCompletion = false; # Home Manager already runs it; twice is slow

          homebrew.enable = true;
          homebrew.casks = [
            "ghostty"
            "font-jetbrains-mono-nerd-font"
            "zen"
            "firefox"
            "raycast"
            "rancher"
            "spotify"
            "claude"
            "bruno"
            "capacities"
            "handbrake-app"
            "grandperspective"
            "onyx"
          ];

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "before-nix";
          home-manager.users."lewis.blackburn" = import ./home.nix;
        }
      ];
    };

    # Fedora: home.nix only; desktop apps come from dnf (see README).
    homeConfigurations.fedora = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfreePredicate = unfree;
      };
      modules = [
        ./home.nix
        {
          home.username = "lewis";
          home.homeDirectory = "/home/lewis";
        }
      ];
    };
  };
}

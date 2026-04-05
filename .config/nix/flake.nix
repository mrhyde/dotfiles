{
  description = "My system configuration";
  inputs = {
    # monorepo w/ recipes ("derivations")
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # manages configs
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # system-level software and settings (macOS)
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # declarative homebrew management
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # OpenGL wrapper for non-NixOS systems
    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      nixgl,
      ...
    }@inputs:
    let
      primaryUser = "jason";
    in
    {
      # build darwin flake using:
      # $ darwin-rebuild build --flake .#<name>
      darwinConfigurations."macbook" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./darwin
          ./hosts/macbook/configuration.nix
        ];
        specialArgs = { inherit inputs self primaryUser; };
      };

      # build wsl home config using:
      # $ home-manager switch --flake .#wsl
      homeConfigurations."wsl" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          ./home
          ./hosts/wsl/configuration.nix
        ];
        extraSpecialArgs = { inherit inputs self primaryUser; };
      };

    };
}

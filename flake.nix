{
  description = "getchoo's nix expressions";

  nixConfig = {
    extra-substituters = ["https://nix-community.cachix.org"];
    extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {nixpkgs, ...}: let
    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});

    packageSet = pkgs:
      with pkgs; {
        treefetch = callPackage ./pkgs/treefetch.nix {};
        swhkd = callPackage ./pkgs/swhkd {};
        vim-just = callPackage ./pkgs/vim-just.nix {};
      };

    overrides = prev: {
      discord = import ./pkgs/discord.nix prev;
      discord-canary = import ./pkgs/discord-canary.nix prev;
    };
  in {
    flakeModules = {
      default = import ./modules/flake;
      homeConfigurations = import ./modules/flake/homeConfigurations.nix;
    };

    formatter = forAllSystems (system: nixpkgsFor.${system}.alejandra);

    herculesCI = {
      ciSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };

    packages = forAllSystems (
      system: let
        pkgs = nixpkgsFor.${system};
        p = packageSet pkgs;
      in
        p // {default = p.treefetch;}
    );

    lib = import ./lib nixpkgs.lib;

    overlays.default = final: prev: packageSet final // overrides prev;
  };
}

{
  description = "getchoo's nix expressions";

  nixConfig = {
    extra-substituters = ["https://nix-community.cachix.org"];
    extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
    forEachSystem = fn: forAllSystems (s: fn nixpkgsFor.${s});

    packageSet = pkgs:
      with pkgs; {
        cartridges = callPackage ./pkgs/cartridges.nix {};
        huion = callPackage ./pkgs/huion.nix {};
        mommy = callPackage ./pkgs/mommy.nix {};
        # broken due to upstrea adopting pnpm
        # theseus = callPackage ./pkgs/theseus.nix {};
        treefetch = callPackage ./pkgs/treefetch.nix {};
        swhkd = callPackage ./pkgs/swhkd {};
        vim-just = callPackage ./pkgs/vim-just.nix {};
        xwaylandvideobridge = callPackage ./pkgs/xwaylandvideobridge.nix {};
      };

    overrides = prev: {
      discord = import ./pkgs/discord.nix prev;
      discord-canary = import ./pkgs/discord-canary.nix prev;
    };
  in {
    flakeModules = {
      default = import ./modules/flake;
      homeConfigurations = import ./modules/flake/homeConfigurations.nix;
      hydraJobs = import ./modules/flake/hydraJobs.nix;
    };

    formatter = forEachSystem (pkgs: pkgs.alejandra);

    herculesCI = let
      ciSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      lib = self.lib {inherit (self) inputs;};
      inherit (lib.ci ciSystems) mkCompatiblePkgs;
    in {
      inherit ciSystems;

      onPush.default = {
        outputs = {
          packages = mkCompatiblePkgs self.packages;
        };
      };
    };

    packages = forEachSystem (
      pkgs: let
        p = packageSet pkgs;
      in
        p // {default = p.treefetch;}
    );

    lib = import ./lib nixpkgs.lib;

    overlays.default = final: prev: packageSet final // overrides prev;

    templates = let
      # string -> string -> {}
      mkTemplate = name: description: {
        path = builtins.path {
          name = "${name}-template-src";
          path = ./templates/${name};
        };
        inherit description;
      };
    in {
      basic = mkTemplate "basic" "minimal boilerplate for my flakes";
      full = mkTemplate "full" "big template for complex flakes (using flake-parts)";
    };
  };
}

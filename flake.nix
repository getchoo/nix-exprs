{
  description = "getchoo's nix expressions";

  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
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
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      });

    forEachSystem = fn:
      forAllSystems (system:
        fn {
          inherit system;
          pkgs = nixpkgsFor.${system};
        });
  in {
    flakeModules = {
      default = import ./modules/flake;
      homeConfigurations = import ./modules/flake/homeConfigurations.nix;
      hydraJobs = import ./modules/flake/hydraJobs.nix;
    };

    formatter = forEachSystem ({pkgs, ...}: pkgs.alejandra);

    checks = let
      ciSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      pkgs = (self.lib.ci ciSystems).mkCompatiblePkgs self.packages;
    in
      nixpkgs.lib.genAttrs ciSystems (sys: pkgs.${sys});

    packages = forEachSystem (
      {pkgs, ...}: let
        inherit (builtins) attrNames filter listToAttrs map readDir substring;
        inherit (nixpkgs.lib) removeSuffix;

        pkgNames = filter (p: substring 0 1 p != "_") (attrNames (readDir ./pkgs));
        pkgs' = map (removeSuffix ".nix") pkgNames;

        p = listToAttrs (map (name: {
            inherit name;
            value = pkgs.${name};
          })
          pkgs');
      in
        p // {default = p.treefetch;}
    );

    lib = import ./lib nixpkgs.lib;

    overlays.default = import ./pkgs;

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

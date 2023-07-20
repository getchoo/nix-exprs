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

    formatter = forEachSystem (p: p.pkgs.alejandra);

    checks = let
      ciSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
      nixpkgs.lib.genAttrs ciSystems (sys: self.packages.${sys});

    packages = forEachSystem (
      {
        pkgs,
        system,
      }: let
        inherit (builtins) attrNames elem filter listToAttrs map readDir substring;
        inherit (nixpkgs.lib) filterAttrs removeSuffix;

        # filter disabled pkgs
        avail =
          filter (p: substring 0 1 p != "_" && p != "default.nix")
          (attrNames (readDir ./pkgs));

        names = map (removeSuffix ".nix") avail;

        p = let
          derivs = listToAttrs (map (name: {
              inherit name;
              value = pkgs.${name};
            })
            names);
        in
          filterAttrs (_: v:
            elem system (v.meta.platforms or []) && !(v.meta.broken or false))
          derivs;
      in
        p // {default = p.treefetch;}
    );

    lib = import ./lib nixpkgs.lib;

    overlays.default = import ./pkgs;

    templates = let
      # string -> string -> {}
      mkTemplate = name: description: {
        path = "${self}/templates/${name}";
        inherit description;
      };
    in {
      basic = mkTemplate "basic" "minimal boilerplate for my flakes";
      full = mkTemplate "full" "big template for complex flakes (using flake-parts)";
    };
  };
}

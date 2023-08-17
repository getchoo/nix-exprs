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

    inherit (nixpkgs) lib;

    forAllSystems = lib.genAttrs systems;
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
      homeManagerModules = import ./modules/flake/homeManagerModules.nix;
      hydraJobs = import ./modules/flake/hydraJobs.nix;
    };

    formatter = forEachSystem (p: p.pkgs.alejandra);

    packages = forEachSystem (
      {
        pkgs,
        system,
      }: let
        p = let
          packages = import ./pkgs pkgs;
        in
          lib.filterAttrs (_: v:
            builtins.elem system (v.meta.platforms or []) && !(v.meta.broken or false))
          packages;
      in
        p // {default = p.treefetch;}
    );

    overlays.default = final: _: import ./pkgs final;

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

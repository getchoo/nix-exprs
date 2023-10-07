{
  description = "getchoo's nix expressions";

  nixConfig = {
    extra-substituters = ["https://cache.garnix.io"];
    extra-trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="];
  };

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = {
    nixpkgs,
    self,
    ...
  }: let
    inherit (nixpkgs) lib;

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = fn: lib.genAttrs systems (sys: fn nixpkgs.legacyPackages.${sys});
  in {
    packages = forAllSystems (
      pkgs: let
        overlay = lib.fix (final: self.overlays.default final pkgs);

        /*
        this filters out packages that may be broken or not supported
        on the current system. packages that have no `version` or `platforms`
        meta attribute are assumed to be valid
        */
        isValid = _: v:
          lib.elem pkgs.system (v.meta.platforms or [pkgs.system]) && !(v.meta.broken or false);

        pkgs' = lib.filterAttrs isValid overlay;
      in
        pkgs' // {default = pkgs'.treefetch;}
    );

    overlays.default = final: prev: (import ./pkgs final prev);

    templates = let
      # string -> string -> {}
      mkTemplate = name: description: {
        path = builtins.path {
          path = ./templates/${name};
          name = "${name}-template";
        };

        inherit description;
      };
    in
      lib.mapAttrs mkTemplate {
        basic = "minimal boilerplate for my flakes";
        full = "big template for complex flakes (using flake-parts)";
        nixos = "minimal boilerplate for flake-based nixos configuration";
      };
  };
}

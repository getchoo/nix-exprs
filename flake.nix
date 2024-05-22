{
  description = "getchoo's nix expressions";

  nixConfig = {
    extra-substituters = ["https://getchoo.cachix.org"];
    extra-trusted-public-keys = ["getchoo.cachix.org-1:ftdbAUJVNaFonM0obRGgR5+nUmdLMM+AOvDOSx0z5tE="];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    nixpkgs,
    self,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = fn: nixpkgs.lib.genAttrs systems (sys: fn nixpkgs.legacyPackages.${sys});
  in {
    checks = forAllSystems (import ./checks.nix self);

    packages = forAllSystems (
      {
        lib,
        pkgs,
        system,
        ...
      }: let
        /*
        this filters out packages that may be broken or not supported
        on the current system. packages that have no `broken` or `platforms`
        meta attribute are assumed to be valid
        */
        isValid = _: v:
          lib.elem pkgs.system (v.meta.platforms or [pkgs.system]) && !(v.meta.broken or false);

        pkgs' = lib.filterAttrs isValid (import ./. {
          nixpkgs = pkgs;
          inherit system;
        });
      in
        pkgs' // {default = pkgs'.treefetch;}
    );

    formatter = forAllSystems (pkgs: pkgs.alejandra);

    overlays.default = final: prev: import ./overlay.nix final prev;

    templates = import ./templates;
  };
}

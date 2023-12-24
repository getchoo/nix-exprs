{
  description = "getchoo's nix expressions";

  nixConfig = {
    extra-substituters = ["https://getchoo.cachix.org"];
    extra-trusted-public-keys = ["getchoo.cachix.org-1:ftdbAUJVNaFonM0obRGgR5+nUmdLMM+AOvDOSx0z5tE="];
  };

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

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
    packages = forAllSystems (
      {
        lib,
        pkgs,
        system,
        ...
      }: let
        overlay = lib.fix (final: self.overlays.default final pkgs);

        /*
        this filters out packages that may be broken or not supported
        on the current system. packages that have no `broken` or `platforms`
        meta attribute are assumed to be valid
        */
        isValid = _: v:
          lib.elem pkgs.system (v.meta.platforms or [pkgs.system]) && !(v.meta.broken or false);

        pkgs' = lib.filterAttrs isValid overlay;
      in
        pkgs' // {default = pkgs'.treefetch;}
    );

    formatter = forAllSystems (pkgs: pkgs.alejandra);

    overlays.default = final: prev: (import ./pkgs final prev);

    templates = let
      # string -> string -> {}
      toTemplate = name: description: {
        path = builtins.path {
          path = ./templates/${name};
          name = "${name}-template";
        };

        inherit description;
      };
    in
      builtins.mapAttrs toTemplate {
        basic = "minimal boilerplate for my flakes";
        full = "big template for complex flakes (using flake-parts)";
        nixos = "minimal boilerplate for flake-based nixos configuration";
      };

    githubWorkflow.matrix = let
      inherit (nixpkgs) lib;

      ciSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
      ];

      platforms = {
        "x86_64-linux" = {
          arch = "x64";
          os = "ubuntu-latest";
        };

        "aarch64-linux" = {
          arch = "aarch64";
          os = "ubuntu-latest";
        };

        "x86_64-darwin" = {
          arch = "x64";
          os = "macos-latest";
        };
      };
    in {
      include = lib.pipe ciSystems [
        (systems: lib.getAttrs systems self.packages)

        (lib.mapAttrsToList (system:
          lib.mapAttrsToList (attr: _: {
            inherit (platforms.${system}) os arch;
            attr = "packages.${system}.${attr}";
          })))

        lib.flatten
      ];
    };
  };
}

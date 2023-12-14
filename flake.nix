{
  description = "getchoo's nix expressions";

  nixConfig = {
    extra-substituters = ["https://cache.mydadleft.me/nix-exprs"];
    extra-trusted-public-keys = ["nix-exprs:mLifiLXlGVkkuFpIbqcrCWkIxKn2GyCkrxOuE7fwLxQ="];
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
      lib.mapAttrs toTemplate {
        basic = "minimal boilerplate for my flakes";
        full = "big template for complex flakes (using flake-parts)";
        nixos = "minimal boilerplate for flake-based nixos configuration";
      };

    githubWorkflow.matrix = let
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

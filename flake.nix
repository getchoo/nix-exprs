{
  description = "getchoo's nix expressions";

  nixConfig = {
    extra-substituters = [ "https://getchoo.cachix.org" ];
    extra-trusted-public-keys = [ "getchoo.cachix.org-1:ftdbAUJVNaFonM0obRGgR5+nUmdLMM+AOvDOSx0z5tE=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # this can be removed with `inputs.treefmt-nix.follows = ""`
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = lib.genAttrs systems;
      nixpkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});
      treefmtFor = forAllSystems (system: treefmt-nix.lib.evalModule nixpkgsFor.${system} ./treefmt.nix);
    in
    {
      checks = forAllSystems (system: {
        treefmt = treefmtFor.${system}.config.build.check self;
      });

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};

          isAvailable = lib.meta.availableOn { inherit system; };

          pkgs' = lib.filterAttrs (lib.const isAvailable) (
            import ./. {
              inherit system;
              inherit nixpkgs;
              inherit pkgs;
              inherit (pkgs) lib;
            }
          );
        in
        pkgs' // { default = pkgs'.treefetch; }
      );

      formatter = forAllSystems (system: treefmtFor.${system}.config.build.wrapper);

      templates = import ./templates;
    };
}

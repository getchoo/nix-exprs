{
  description = "getchoo's nix expressions";

  nixConfig = {
    extra-substituters = [ "https://getchoo.cachix.org" ];
    extra-trusted-public-keys = [ "getchoo.cachix.org-1:ftdbAUJVNaFonM0obRGgR5+nUmdLMM+AOvDOSx0z5tE=" ];
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      inherit (nixpkgs) lib;

      # Support all systems exported by Nixpkgs
      systems = lib.systems.flakeExposed;
      # But separate our primarily supported systems
      tier1Systems = with lib.platforms; lib.intersectLists (aarch64 ++ aarch64) (darwin ++ linux);

      forAllSystems = lib.genAttrs systems;
      forTier1Systems = lib.genAttrs tier1Systems;
      nixpkgsFor = nixpkgs.legacyPackages;

      mkModule =
        {
          name,
          type,
          imports,
        }:
        {
          __file = "${self.outPath}/flake.nix#${type}Modules.${name}";
          inherit imports;
        };

    in
    {
      checks = forTier1Systems (
        system:
        let
          pkgs = nixpkgsFor.${system};

          mkCheck =
            name: deps: script:
            pkgs.runCommand name { nativeBuildInputs = deps; } script;
        in
        {
          deadnix = mkCheck "check-deadnix" [ pkgs.deadnix ] "deadnix --fail ${self}";
          nixfmt = mkCheck "check-nixfmt" [ pkgs.nixfmt-rfc-style ] "nixfmt --check ${self}";
          statix = mkCheck "check-statix" [ pkgs.statix ] "statix check ${self}";
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};

          isAvailable = lib.meta.availableOn { inherit system; };
          pkgs' = lib.filterAttrs (lib.const isAvailable) (import ./default.nix { inherit pkgs; });
        in
        pkgs' // { default = pkgs'.treefetch or pkgs.emptyFile; }
      );

      homeModules = {
        riff = mkModule {
          name = "riff";
          type = "home";
          imports = [ ./modules/home/riff.nix ];
        };
      };

      formatter = forTier1Systems (system: nixpkgsFor.${system}.nixfmt-rfc-style);

      templates =
        let
          toTemplate = name: description: {
            path = ./templates + "/${name}";
            inherit description;
          };
        in
        lib.mapAttrs toTemplate {
          standard = "Minimal boilerplate for my Flakes";
          nixos = "Minimal boilerplate for a Flake-based NixOS configuration";
        };
    };
}

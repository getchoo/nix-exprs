{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    naersk,
    pre-commit-hooks,
    ...
  }: let
    supportedSystems = with utils.lib.system; [
      x86_64-linux
      x86_64-darwin
      aarch64-linux
      aarch64-darwin
    ];
    packageSet = pkgs:
      with pkgs; rec {
        treefetch = callPackage ./pkgs/treefetch.nix {inherit naersk;};
        material-color-utilities = callPackage ./pkgs/material-color-utilities.nix {};
        gradience = callPackage ./pkgs/gradience.nix {inherit material-color-utilities;};
        swhkd = callPackage ./pkgs/swhkd.nix {inherit naersk;};
        vim-just = callPackage ./pkgs/vim-just.nix {};
      };
    overrides = prev: {
      discord-canary = import ./pkgs/discord-canary.nix prev;
    };
  in
    utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # formatting is taken care of by gh actions :)
            deadnix.enable = true;
            markdownlint.enable = true;
          };
        };
      };

      devShells.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        packages = with pkgs; [
          nodePackages.markdownlint-cli
          deadnix
        ];
      };

      formatter = pkgs.alejandra;

      packages = let
        p = packageSet pkgs;
      in
        p // {default = p.treefetch;};
    })
    // {
      overlays.default = final: prev: packageSet final // overrides prev;
    };
}

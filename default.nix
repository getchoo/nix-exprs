let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
in
  {
    pkgs ?
      import nixpkgs {
        config = {};
        overlays = [];
        inherit system;
      },
    lib ? pkgs.lib,
    nixpkgs ? (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
      sha256 = lock.nodes.nixpkgs.locked.narHash;
    }),
    system ? builtins.currentSystem,
  }: let
    inherit (pkgs) callPackage;
  in
    lib.fix (final:
      lib.packagesFromDirectoryRecursive {
        inherit callPackage;
        directory = ./pkgs;
      }
      // {
        clippy-sarif = callPackage ./pkgs/clippy-sarif/package.nix {inherit (final) clippy-sarif;};

        flat-manager = callPackage ./pkgs/flat-manager/package.nix {inherit (final) flat-manager;};
        flat-manager-client = callPackage ./pkgs/flat-manager-client/package.nix {inherit (final) flat-manager;};

        papa = callPackage ./pkgs/papa/package.nix {inherit (final) papa;};
      })

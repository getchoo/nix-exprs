let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
in
{
  pkgs ? import nixpkgs {
    config = { };
    overlays = [ ];
    inherit system;
  },
  lib ? pkgs.lib,
  nixpkgs ? (
    fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
      sha256 = lock.nodes.nixpkgs.locked.narHash;
    }
  ),
  system ? builtins.currentSystem,
}:
let
  packages =
    lib.packagesFromDirectoryRecursive {
      inherit (pkgs) callPackage;
      directory = ./pkgs;
    }
    // {
      flat-manager = pkgs.callPackage ./pkgs/flat-manager/package.nix {
        inherit (packages) flat-manager;
      };
      flat-manager-client = pkgs.callPackage ./pkgs/flat-manager-client/package.nix {
        inherit (packages) flat-manager;
      };

      papa = pkgs.callPackage ./pkgs/papa/package.nix { inherit (packages) papa; };
    };
in
packages

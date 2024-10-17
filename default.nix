let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
in
{
  pkgs ? import nixpkgs {
    config = { };
    overlays = [ ];
    inherit system;
  },
  nixpkgs ? (
    fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
      sha256 = lock.nodes.nixpkgs.locked.narHash;
    }
  ),
  system ? builtins.currentSystem,
}:
let
  inherit (pkgs) lib;
  packageDirectory = ./pkgs;

  scope = lib.makeScope pkgs.newScope (
    final:
    lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = packageDirectory;
    }
  );

  # Filter extraneous attributes from the scope, based on the files in our package directory
  packageFileNames = builtins.attrNames (builtins.readDir packageDirectory);
  packages = lib.getAttrs packageFileNames scope;
in
packages

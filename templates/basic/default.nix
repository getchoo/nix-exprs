{
  pkgs ? import nixpkgs {
    inherit system;
    config = { };
    overlays = [ ];
  },
  lib ? pkgs.lib,
  nixpkgs ? <nixpkgs>,
  system ? builtins.currentSystem,
}:
{
  inherit (pkgs) lib;
}

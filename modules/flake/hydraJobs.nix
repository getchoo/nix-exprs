{
  lib,
  flake-parts-lib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkTransposedPerSystemModule;
in
  mkTransposedPerSystemModule {
    name = "hydraJobs";
    option = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = {};
      description = ''
        An attribute set containing home-manager homeConfigurations
      '';
    };
    file = ./hydraJobs.nix.nix;
  }

{
  lib,
  flake-parts-lib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in {
  options = {
    flake = mkSubmoduleOptions {
      hydraJobs = mkOption {
        type = types.lazyAttrsOf types.raw;
        default = {};
        description = ''
          A collection of jobsets for Hydra. See https://nixos.wiki/wiki/Hydra#Flake_jobset
        '';
        example = ''
          {
          	inherit (self) packages;
          }
        '';
      };
    };
  };
}

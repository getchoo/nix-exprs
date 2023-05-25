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
          An attribute set containing home-manager homeConfigurations
        '';
      };
    };
  };
}

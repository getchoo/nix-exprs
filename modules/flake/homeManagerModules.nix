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
      homeManagerModules = mkOption {
        type = types.lazyAttrsOf types.unspecified;
        default = {};
        description = ''
          Home Manager modules
        '';
      };
    };
  };
}

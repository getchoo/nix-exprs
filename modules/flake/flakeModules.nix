{
  self,
  lib,
  flake-parts-lib,
  ...
}: let
  inherit (lib) mapAttrs mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in {
  options = {
    flake = mkSubmoduleOptions {
      flakeModules = mkOption {
        type = types.lazyAttrsOf types.unspecified;
        default = {};
        apply = mapAttrs (k: v: {
          _file = "${toString self.outPath}/flake.nix#flakeModules.${k}";
          imports = [v];
        });
        description = ''
          flake-parts modules
        '';
      };
    };
  };
}

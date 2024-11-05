{ flake-parts-lib, ... }:
{
  options = {
    perSystem = flake-parts-lib.mkPerSystemOption (
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        namespace = "quickChecks";
        cfg = config.${namespace};

        checkSubmodule =
          { config, name, ... }:
          {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                default = "check-" + name;
                description = "Name of the derivation used for the script.";
              };

              dependencies = lib.mkOption {
                type = lib.types.listOf lib.types.package;
                default = [ ];
                description = "Packages used in the script.";
              };

              script = lib.mkOption {
                type = lib.types.lines;
                description = "Script to run as the check.";
              };

              package = lib.mkOption {
                type = lib.types.package;
                readOnly = true;
                description = "Package that runs the check.";
              };
            };

            config = {
              package = pkgs.runCommand config.name { nativeBuildInputs = config.dependencies; } (
                lib.concatLines [
                  config.script
                  "touch $out"
                ]
              );
            };
          };
      in
      {
        options.${namespace} = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule checkSubmodule);
          default = { };
          description = "An attribute set of check scripts.";
        };

        config = {
          checks = lib.mapAttrs (lib.const (lib.getAttr "package")) cfg;
        };
      }
    );
  };
}

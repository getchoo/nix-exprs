{
  config,
  lib,
  self,
  ...
}: let
  cfg = config.githubWorkflowGenerator;

  inherit
    (builtins)
    attrNames
    filter
    ;

  inherit
    (lib)
    elem
    flatten
    getAttrs
    literalExpression
    mapAttrsToList
    mdDoc
    mkOption
    types
    ;

  supportedOutputs = [
    "apps"
    "checks"
    "devShells"
    "darwinConfigurations"
    "homeConfigurations"
    "nixosConfigurations"
    "packages"
  ];

  platformMap = {
    options = {
      arch = mkOption {
        description = mdDoc "the architecture of a system";
        type = types.str;
        default = null;
        example = literalExpression "x86_64";
      };

      os = mkOption {
        description = mdDoc "the name of an os supported by github runners";
        type = types.str;
        default = null;
        example = literalExpression "ubuntu-latest";
      };
    };
  };

  overrides = {
    options = {
      systems = mkOption {
        description = mdDoc "list of systems to build an output for";
        type = types.listOf types.str;
        default = builtins.attrNames cfg.platforms;
      };
    };
  };

  mkMatrix = {
    output,
    systems ? (attrNames cfg.platforms),
  }:
    if (lib.elem output ["nixosConfigurations" "darwinConfigurations"])
    then
      mkMatrixFlat {
        inherit output;
        suffix = ".config.system.build.toplevel";
      }
    else if (output == "homeConfigurations")
    then
      mkMatrixFlat {
        inherit output;
        suffix = ".activationPackage";
      }
    else
      flatten (
        mapAttrsToList
        (
          system:
            mapAttrsToList (
              attr: _: {
                inherit (cfg.platforms.${system}) os arch;
                attr = "${output}.${system}.${attr}";
              }
            )
        )
        (getAttrs systems self.${output})
      );

  mkMatrixFlat = {
    output,
    suffix ? "",
  }:
    mapAttrsToList (
      attr: deriv: {
        inherit (cfg.platforms.${deriv.pkgs.system}) os arch;
        attr = "${output}.${attr}${suffix}";
      }
    )
    self.${output};

  jobs = let
    self' = getAttrs cfg.outputs self;
  in
    flatten (
      mapAttrsToList (
        output: _:
          mkMatrix ({inherit output;} // cfg.overrides.${output} or {})
      )
      self'
    );
in {
  options = {
    githubWorkflowGenerator = {
      outputs = mkOption {
        description = mdDoc "outputs to include in workflow";
        type = types.listOf types.str;
        default = filter (output: elem output supportedOutputs) (attrNames self);
      };

      platforms = mkOption {
        description = mdDoc ''
          an attrset that can map a nix system to an architecture and os supported by github
        '';
        type = types.attrsOf (types.submodule platformMap);
        default = {
          "x86_64-linux" = {
            arch = "x86_64";
            os = "ubuntu-latest";
          };

          "aarch64-linux" = {
            arch = "aarch64";
            os = "ubuntu-latest";
          };

          "x86_64-darwin" = {
            arch = "x86_64";
            os = "macos-latest";
          };
        };
      };

      overrides = mkOption {
        description = mdDoc "overrides for mkMatrix args";
        type = types.attrsOf (types.submodule overrides);
        default = {};
        example = literalExpression ''
          {
            githubworkflowGenerator.overrides = {
              checks.systems = [ "x86_64-linux" ];
            };
          }
        '';
      };
    };
  };

  config.flake.githubWorkflow = {matrix.include = jobs;};
}

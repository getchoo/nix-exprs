{
  config,
  lib,
  inputs,
  withSystem,
  ...
}:

let
  namespace = "configurations";
  cfg = config.${namespace};

  /**
    Submodule representing common options between builder functions
    like `nixosSystem`, `darwinSystem`, and `homeManagerConfiguration`
  */
  configurationBuilderSubmodule =
    { options, ... }:

    {
      freeformType = lib.types.attrsOf lib.types.any;

      options = {
        builder = lib.mkOption {
          type = lib.types.functionTo options.configuration.type;
        };

        modules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [ ];
          apply = lib.concat [
            (
              { pkgs, ... }:

              {
                _module.args.inputs' = withSystem pkgs.stdenv.hostPlatform.system ({ inputs', ... }: inputs');
              }
            )
          ];
          description = "The modules to include in the configuration.";
          example = lib.literalExpression ''
            [ ./configuration.nix ]
          '';
        };

        specialArgs = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.raw;
          default = { };
          apply = lib.recursiveUpdate { inherit inputs; };
          description = "Extra arguments to pass to all modules, that are available in `imports` but can not be extended or overridden by the `modules`.";
          example = lib.literalExpression ''
            { foo = "bar"; }
          '';
        };

        configuration = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.raw;
          internal = true;
          readOnly = true;
        };
      };
    };

  /**
    Submodule representing a nixosConfiguration builder definition and it's accompanying options
  */
  nixosConfigurationSubmodule = lib.types.submodule (
    { config, ... }:

    {
      imports = [ configurationBuilderSubmodule ];

      options = {
        builder = lib.mkOption {
          default = inputs.nixpkgs.lib.nixosSystem or null;
          defaultText = "inputs.nixpkgs.lib.nixosSystem or null";
          description = "Builder for a NixOS configuration.";
          example = lib.literalExpression "inputs.nixpkgs-stable.lib.nixosSystem";
        };

        modulesLocation = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "A default location for modules that aren't passed by path, used for error messages.";
        };
      };

      config = {
        configuration = config.builder (
          lib.removeAttrs config [
            "_module"
            "builder"
            "configuration"
          ]
        );
      };
    }
  );

  /**
    Submodule representing a darwinConfiguration builder definition and it's accompanying options
  */
  darwinConfigurationSubmodule = lib.types.submodule (
    { config, ... }:

    {
      imports = [ configurationBuilderSubmodule ];

      options = {
        builder = lib.mkOption {
          default = (inputs.nix-darwin or inputs.darwin or { }).lib.darwinSystem or null;
          defaultText = "(inputs.nix-darwin or input.darwin or { }).lib.darwinSystem or null";
          description = "Builder for a nix-darwin configuration.";
          example = lib.literalExpression "inputs.nix-darwin.lib.nixosSystem";
        };
      };

      config = {
        configuration = config.builder (
          lib.removeAttrs config [
            "_module"
            "builder"
            "configuration"
          ]
        );
      };
    }
  );

  /**
    Submodule representing a homeConfiguration builder definition and it's accompanying options
  */
  homeConfigurationSubmodule = lib.types.submodule (
    { config, ... }:

    {
      imports = [ configurationBuilderSubmodule ];

      options = {
        builder = lib.mkOption {
          default = inputs.home-manager.lib.homeManagerConfiguration or null;
          defaultText = "inputs.home-manager.lib.homeManagerConfiguration or null";
          description = "Builder for a home-manager configuration.";
          example = lib.literalExpression "inputs.hm.lib.homeManagerConfiguration";
        };

        pkgs = lib.mkOption {
          type = lib.types.pkgs;
          description = "An instance of Nixpkgs to use in the configuration.";
          example = lib.literalExpression ''
            withSystem "x86_64-linux" ({ pkgs, ... }: pkgs)
          '';
        };
      };

      config = {
        configuration = config.builder (
          lib.removeAttrs config [
            "_module"
            "builder"
            "configuration"
            "specialArgs"
          ]
          // {
            extraSpecialArgs = config.specialArgs;
          }
        );
      };
    }
  );

  configurationOption = lib.mkOption {
    default = { };
  };

  configurations = lib.mapAttrs (lib.const (lib.mapAttrs (lib.const (cfg': cfg'.configuration)))) cfg;
in
{
  options.${namespace} = {
    nixos = configurationOption // {
      type = lib.types.attrsOf nixosConfigurationSubmodule;
      description = "A map of NixOS configuration names and options.";
      example = lib.literalExpression ''
        {
          my-machine = { modules = [ ./configuration.nix ]; }
        }
      '';
    };

    darwin = configurationOption // {
      type = lib.types.attrsOf darwinConfigurationSubmodule;
      description = "A map of nix-darwin configuration names and options.";
      example = lib.literalExpression ''
        {
          my-mac = { modules = [ ./darwin-configuration.nix ]; }
        }
      '';
    };

    home = configurationOption // {
      type = lib.types.attrsOf homeConfigurationSubmodule;
      description = "A map of home-manager configuration names and options.";
      example = lib.literalExpression ''
        {
          my-home = { modules = [ ./home.nix ]; }
        }
      '';
    };
  };

  config.flake = {
    nixosConfigurations = configurations.nixos;
    darwinConfigurations = configurations.darwin;
    homeConfigurations = configurations.home;
  };
}

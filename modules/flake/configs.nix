{
  config,
  lib,
  inputs,
  withSystem,
  ...
}:
let
  cfg = config.configurations;

  applySpecialArgs = lib.recursiveUpdate { inherit inputs; };
  applyModules = lib.concat (
    lib.toList (
      { pkgs, ... }:
      {
        _module.args.inputs' = withSystem pkgs.stdenv.hostPlatform.system ({ inputs', ... }: inputs');
      }
    )
  );

  nixosSystem =
    {
      nixpkgs,
      modules,
      specialArgs,
      ...
    }@args:
    nixpkgs.lib.nixosSystem (
      lib.removeAttrs args [ "nixpkgs" ]
      // {
        modules = applyModules modules;
        specialArgs = applySpecialArgs specialArgs;
      }
    );

  darwinSystem =
    {
      nix-darwin,
      modules,
      specialArgs,
      ...
    }@args:
    nix-darwin.lib.darwinSystem (
      lib.removeAttrs args [ "nix-darwin" ]
      // {
        modules = applyModules modules;
        specialArgs = applySpecialArgs specialArgs;
      }
    );

  homeManagerConfiguration =
    {
      home-manager,
      modules,
      extraSpecialArgs,
      ...
    }@args:
    home-manager.lib.homeManagerConfiguration (
      lib.removeAttrs args [ "home-manager" ]
      // {
        modules = applyModules modules;
        extraSpecialArgs = applySpecialArgs extraSpecialArgs;
      }
    );

  modulesType = lib.types.listOf lib.types.deferredModule;

  specialArgsOption = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
    description = "Extra arguments to pass to all modules, that are available in `imports` but can not be extended or overridden by the `modules`.";
    example = lib.literalExpression ''
      { foo = "bar"; }
    '';
  };

  legacyPackagesType = lib.types.lazyAttrsOf lib.types.raw;
  flakeType = legacyPackagesType;

  freeformType = lib.types.attrsOf lib.types.any;

  nixosConfigurationSubmodule = {
    inherit freeformType;

    options = {
      nixpkgs = lib.mkOption {
        type = flakeType;
        default = inputs.nixpkgs or (throw "`nixpkgs` must be defined");
        defaultText = "inputs.nixpkgs";
        description = "A nixpkgs input.";
        example = lib.literalExpression "inputs.nixpkgs-stable";
      };

      modules = lib.mkOption {
        type = modulesType;
        default = [ ];
        description = "The NixOS modules to include in the system configuration.";
        example = lib.literalExpression ''
          [ ./configuration.nix ]
        '';
      };

      specialArgs = specialArgsOption;
      modulesLocation = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "A default location for modules that aren't passed by path, used for error messages.";
      };
    };
  };

  darwinConfigurationSubmodule = {
    inherit freeformType;

    options = {
      nix-darwin = lib.mkOption {
        type = flakeType;
        default = inputs.nix-darwin or inputs.darwin or (throw "`nix-darwin` must be defined");
        defaultText = "inputs.nix-darwin or inputs.darwin";
        description = "A nix-darwin input.";
        example = lib.literalExpression "inputs.nix-darwin";
      };

      modules = lib.mkOption {
        type = modulesType;
        default = [ ];
        description = "The Darwin modules to include in the system configuration.";
        example = lib.literalExpression ''
          [ ./configuration.nix ]
        '';
      };

      specialArgs = specialArgsOption;
    };
  };

  homeConfigurationSubmodule = {
    inherit freeformType;

    options = {
      home-manager = lib.mkOption {
        type = flakeType;
        default = inputs.home-manager or (throw "`home-manager` must be defined");
        defaultText = "inputs.home-manager";
        description = "A home-manager input.";
        example = lib.literalExpression "inputs.hm";
      };

      pkgs = lib.mkOption {
        type = legacyPackagesType;
        description = "An instance of Nixpkgs to use in the configuration.";
        example = lib.literalExpression ''
          withSystem "x86_64-linux" ({ pkgs, ... }: pkgs)
        '';
      };

      modules = lib.mkOption {
        type = modulesType;
        default = [ ];
        description = "The home-manager modules to include in the configuration.";
        example = lib.literalExpression ''
          [ ./home.nix ]
        '';
      };

      extraSpecialArgs = specialArgsOption;
    };
  };
in
{
  options.configurations = {
    nixos = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule nixosConfigurationSubmodule);
      default = { };
      apply = lib.mapAttrs (lib.const nixosSystem);
      description = "A map of configuration names and options for `nixosSystem`.";
      example = lib.literalExpression ''
        {
          my-machine = { modules = [ ./configuration.nix ]; }
        }
      '';
    };

    darwin = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule darwinConfigurationSubmodule);
      default = { };
      apply = lib.mapAttrs (lib.const darwinSystem);
      description = "A map of configuration names and options for `darwinSystem`.";
      example = lib.literalExpression ''
        {
          my-mac = { modules = [ ./darwin-configuration.nix ]; }
        }
      '';
    };

    home = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule homeConfigurationSubmodule);
      default = { };
      apply = lib.mapAttrs (lib.const homeManagerConfiguration);
      description = "A map of configuration names and options for `homeManagerConfiguration`.";
      example = lib.literalExpression ''
        {
          my-home = { modules = [ ./home.nix ]; }
        }
      '';
    };
  };

  config.flake = {
    nixosConfigurations = cfg.nixos;
    darwinConfigurations = cfg.darwin;
    homeConfigurations = cfg.home;
  };
}

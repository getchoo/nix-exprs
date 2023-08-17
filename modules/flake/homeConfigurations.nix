{
  lib,
  flake-parts-lib,
  ...
}: let
  inherit (lib) mkOption types literalExpression;
  inherit (flake-parts-lib) mkTransposedPerSystemModule;
in
  mkTransposedPerSystemModule {
    name = "homeConfigurations";
    option = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = {};
      description = ''
        Instantiated home-manager configurations. Used by `home-manager`
      '';
      example = literalExpression ''
        {
        	user = inputs.home-manager.homeManagerConfiguration {
        		pkgs = import inputs.nixpkgs {inherit system;};
        		modules = [
        			./my-users/home.nix
        		];
        	};
        }
      '';
    };

    file = ./homeConfigurations.nix;
  }

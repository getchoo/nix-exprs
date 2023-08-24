{self, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  } @ args: {
    pre-commit = {
      settings.hooks = {
        alejandra.enable = true;
        deadnix.enable = true;
        nil.enable = true;
        statix.enable = true;
      };
    };

    devShells = {
      default = pkgs.mkShell {
        shellHook = config.pre-commit.installationScript;
        packages = with pkgs; [
          self.formatter.${args.system}
          deadnix
          nil
          statix
        ];
      };
    };
  };
}

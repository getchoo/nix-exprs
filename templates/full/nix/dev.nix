{
  perSystem = {
    pkgs,
    config,
    self',
    ...
  }: {
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
          self'.formatter
          deadnix
          nil
          statix
        ];
      };
    };

    formatter = pkgs.alejandra;
  };
}

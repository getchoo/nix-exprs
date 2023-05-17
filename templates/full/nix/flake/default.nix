{
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    checks = {
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = builtins.path {
          name = "flake-src";
          path = ../../.;
        };

        hooks = {
          alejandra.enable = true;
          deadnix.enable = true;
          nil.enable = true;
          statix.enable = true;
        };
      };
    };

    devShells = let
      inherit (pkgs) mkShell;
    in {
      default = mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        packages = with pkgs; [
          alejandra
          deadnix
          nil
          statix
        ];
      };
    };

    formatter = pkgs.alejandra;
  };
}

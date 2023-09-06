{self, ...}: {
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: {
    packages = let
      inherit (builtins) elem;
      inherit (lib) filterAttrs fix;

      unfiltered = fix (
        final:
          self.overlays.default (final // {inherit (pkgs) nodePackages darwin;}) pkgs
      );

      p = filterAttrs (_: v:
        elem system (v.meta.platforms or []) && !(v.meta.broken or false))
      unfiltered;
    in
      p // {default = p.treefetch;};
  };

  flake = {
    overlays.default = final: prev: (import ./all-packages.nix final prev);
  };
}

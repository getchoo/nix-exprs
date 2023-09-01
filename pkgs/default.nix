_: {
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: {
    packages = let
      inherit (builtins) elem;
      inherit (lib) filterAttrs makeScope;
      inherit (pkgs) newScope;

      p = let
        packages = makeScope newScope (final: import ./all-packages.nix final pkgs);
      in
        filterAttrs (_: v:
          elem system (v.meta.platforms or []) && !(v.meta.broken or false))
        packages;
    in
      p // {default = p.treefetch;};
  };

  flake = {
    overlays.default = final: prev: (import ./all-packages.nix final prev);
  };
}

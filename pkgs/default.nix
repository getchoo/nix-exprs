_: {
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: {
    packages = let
      p = let
        packages = import ./all-packages.nix {prev = pkgs;};
      in
        lib.filterAttrs (_: v:
          builtins.elem system (v.meta.platforms or []) && !(v.meta.broken or false))
        packages;
    in
      p // {default = p.treefetch;};
  };

  flake.overlays.default = final: prev: import ./all-packages.nix {inherit final prev;};
}

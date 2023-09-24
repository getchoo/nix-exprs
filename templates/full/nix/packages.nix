{self, ...}: {
  flake.overlays.default = _: prev: {
    foo = prev.callPackage ./derivation.nix {inherit self;};
  };

  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    package = let
      fixup = lib.filterAttrs (
        _: v:
          builtins.elem (v.meta.platforms or []) && !(v.meta.broken or false)
      );

      unfiltered = lib.fix (final: self.overlays.default final pkgs);
      pkgs' = fixup unfiltered;
    in {
      inherit (pkgs') foo;
      default = pkgs'.foo;
    };
  };
}

{
  self,
  inputs,
  ...
}: {
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [self.overlays.default];
    };

    packages = let
      p = let
        packages = import ./all-packages.nix pkgs;
      in
        lib.filterAttrs (_: v:
          builtins.elem system (v.meta.platforms or []) && !(v.meta.broken or false))
        packages;
    in
      p // {default = p.treefetch;};
  };

  flake.overlays.default = final: _: import ./all-packages.nix final;
}

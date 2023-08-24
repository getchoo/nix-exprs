{
  self,
  inputs,
  ...
}: let
  version = builtins.substring 0 8 self.lastModifiedDate or "dirty";

  filterPkgs =
    inputs.nixpkgs.lib.filterAttrs (_: v:
      builtins.elem (v.meta.platforms or []) && !(v.meta.broken or false));

  packageFn = pkgs: {
    hello = pkgs.callpackage ./hello.nix {inherit self version;};
  };
in {
  flake.overlays = _: prev: (packageFn prev);

  perSystem = {pkgs, ...}: {
    packages = let
      p = filterPkgs (packageFn pkgs);
    in
      p // {default = p.hello;};
  };
}

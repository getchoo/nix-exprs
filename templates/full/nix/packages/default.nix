{self, ...}: let
  version = builtins.substring 0 8 self.lastModifiedDate;

  packageFn = pkgs: {
    hello = pkgs.callPackage ./hello.nix {inherit version;};
  };
in {
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  flake.overlays = final: _: packageFn final;

  perSystem = {pkgs, ...}: {
    packages = let
      p = packageFn pkgs;
    in
      p // {default = p.hello;};
  };
}

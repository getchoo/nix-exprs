{ self, ... }:
let
  version = self.shortRev or self.dirtyShortRev or "unknown";
in
{
  flake.overlays.default = _: prev: {
    hello = prev.callPackage ./derivation.nix { inherit version; };
  };

  perSystem =
    { pkgs, self', ... }:
    {
      package = {
        hello = pkgs.callPackage ./derivation.nix { inherit version; };
        default = self'.packages.hello;
      };
    };
}

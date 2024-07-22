{ self, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    {
      package = {
        hello = pkgs.callPackage ./derivation.nix {
          version = self.shortRev or self.dirtyShortRev or "unknown";
        };

        default = self'.packages.hello;
      };
    };
}

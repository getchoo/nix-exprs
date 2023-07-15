final: _: let
  inherit (final) callPackage;
in {
  # original packages
  cartridges = callPackage ./cartridges.nix {};
  cfspeedtest = callPackage ./cfspeedtest.nix {};
  check-pr = callPackage ./check-pr.nix {};
  huion = callPackage ./huion.nix {};
  mommy = callPackage ./mommy.nix {};
  theseus = callPackage ./theseus {};
  treefetch = callPackage ./treefetch.nix {};
  swhkd = callPackage ./swhkd {};
  vim-just = callPackage ./vim-just.nix {};
  xwaylandvideobridge = callPackage ./xwaylandvideobridge.nix {};
}

pkgs: let
  inherit (pkgs) callPackage;
in {
  # original packages
  cfspeedtest = callPackage ./cfspeedtest.nix {};
  check-pr = callPackage ./check-pr.nix {};
  fastfetch = callPackage ./fastfetch.nix {};
  huion = callPackage ./huion.nix {};
  mommy = callPackage ./mommy.nix {};
  theseus = callPackage ./theseus.nix {
    inherit (pkgs.nodePackages) pnpm;
    inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices Security WebKit;
  };
  treefetch = callPackage ./treefetch.nix {};
  swhkd = callPackage ./swhkd {};
  vim-just = callPackage ./vim-just.nix {};
  xwaylandvideobridge = callPackage ./xwaylandvideobridge.nix {};
}

pkgs: let
  inherit (pkgs) callPackage;
in {
  # original packages
  cfspeedtest = callPackage ./cfspeedtest.nix {};
  check-pr = callPackage ./check-pr.nix {};
  fastfetch = callPackage ./fastfetch.nix {};
  huion = callPackage ./huion.nix {};
  mommy = callPackage ./mommy.nix {};
  nixgc = callPackage ./nixgc.nix {};
  theseus-unwrapped = callPackage ./theseus {
    inherit (pkgs.nodePackages) pnpm;
    inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices Security WebKit;
  };
  theseus = callPackage ./theseus/wrapper.nix {};
  treefetch = callPackage ./treefetch.nix {};
  swhkd = callPackage ./swhkd {};
  vim-just = callPackage ./vim-just.nix {};
  xwaylandvideobridge = callPackage ./xwaylandvideobridge.nix {};
}

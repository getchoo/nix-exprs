final: prev: let
  inherit (prev) callPackage;
in {
  cfspeedtest = callPackage ./cfspeedtest.nix {};

  check-pr = callPackage ./check-pr.nix {};

  clippy-sarif = callPackage ./clippy-sarif.nix {};

  huion = callPackage ./huion.nix {};

  klassy = prev.libsForQt5.callPackage ./klassy.nix {};

  mommy = callPackage ./mommy.nix {};

  nixgc = callPackage ./nixgc.nix {};

  modrinth-app-unwrapped = callPackage ./modrinth-app {
    inherit (final.nodePackages) pnpm;
    inherit (final.darwin.apple_sdk.frameworks) CoreServices Security WebKit;
  };

  modrinth-app = callPackage ./modrinth-app/wrapper.nix {
    inherit (final) modrinth-app-unwrapped;
  };

  treefetch = callPackage ./treefetch.nix {};

  swhkd = callPackage ./swhkd {};

  vim-just = callPackage ./vim-just.nix {};

  xwaylandvideobridge = callPackage ./xwaylandvideobridge.nix {};
}

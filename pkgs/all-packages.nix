{
  final ? {},
  prev,
}: let
  inherit (prev) callPackage;
  callPackage' =
    final.callPackage or prev.lib.callPackageWith (prev // packages);

  packages = {
    cfspeedtest = callPackage ./cfspeedtest.nix {};
    check-pr = callPackage ./check-pr.nix {};
    fastfetch = callPackage ./fastfetch.nix {};
    huion = callPackage ./huion.nix {};
    klassy = prev.libsForQt5.callPackage ./klassy.nix {};
    mommy = callPackage ./mommy.nix {};
    nixgc = callPackage ./nixgc.nix {};
    modrinth-app-unwrapped = callPackage ./modrinth-app {
      inherit (prev.nodePackages) pnpm;
      inherit (prev.darwin.apple_sdk.frameworks) CoreServices Security WebKit;
    };
    modrinth-app = callPackage' ./modrinth-app/wrapper.nix {};
    treefetch = callPackage ./treefetch.nix {};
    swhkd = callPackage ./swhkd {};
    vim-just = callPackage ./vim-just.nix {};
    xwaylandvideobridge = callPackage ./xwaylandvideobridge.nix {};
  };
in
  packages

final: prev: let
  inherit (prev) callPackage;
in
  prev.lib.packagesFromDirectoryRecursive {
    inherit callPackage;
    directory = ./pkgs;
  }
  // {
    clang-tidy-sarif = callPackage ./pkgs/clang-tidy-sarif.nix {inherit (final) clang-tidy-sarif;};
    clippy-sarif = callPackage ./pkgs/clippy-sarif.nix {inherit (final) clippy-sarif;};
    hadolint-sarif = callPackage ./pkgs/hadolint-sarif.nix {inherit (final) hadolint-sarif;};
    sarif-fmt = callPackage ./pkgs/sarif-fmt.nix {inherit (final) sarif-fmt;};

    flat-manager = callPackage ./pkgs/flat-manager.nix {inherit (final) flat-manager;};
    flat-manager-client = callPackage ./pkgs/flat-manager-client.nix {inherit (final) flat-manager;};

    klassy = prev.libsForQt5.callPackage ./pkgs/klassy.nix {};

    papa = callPackage ./pkgs/papa/package.nix {inherit (final) papa;};
  }

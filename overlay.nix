final: prev: let
  inherit (prev) callPackage;
in
  prev.lib.packagesFromDirectoryRecursive {
    inherit callPackage;
    directory = ./pkgs;
  }
  // {
    clang-tidy-sarif = callPackage ./pkgs/clang-tidy-sarif/package.nix {inherit (final) clang-tidy-sarif;};
    clippy-sarif = callPackage ./pkgs/clippy-sarif/package.nix {inherit (final) clippy-sarif;};
    hadolint-sarif = callPackage ./pkgs/hadolint-sarif/package.nix {inherit (final) hadolint-sarif;};
    sarif-fmt = callPackage ./pkgs/sarif-fmt/package.nix {inherit (final) sarif-fmt;};

    flat-manager = callPackage ./pkgs/flat-manager/package.nix {inherit (final) flat-manager;};
    flat-manager-client = callPackage ./pkgs/flat-manager-client/package.nix {inherit (final) flat-manager;};

    papa = callPackage ./pkgs/papa/package.nix {inherit (final) papa;};
  }

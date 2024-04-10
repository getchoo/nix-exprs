final: prev: let
  inherit (prev) callPackage;
in
  prev.lib.packagesFromDirectoryRecursive {
    inherit (prev) callPackage;
    directory = ./pkgs;
  }
  // {
    clang-tidy-sarif = callPackage ./pkgs/clang-tidy-sarif.nix {inherit (final) clang-tidy-sarif;};
    clippy-sarif = callPackage ./pkgs/clippy-sarif.nix {inherit (final) clippy-sarif;};
    hadolint-sarif = callPackage ./pkgs/hadolint-sarif.nix {inherit (final) hadolint-sarif;};
    sarif-fmt = callPackage ./pkgs/sarif-fmt.nix {inherit (final) sarif-fmt;};
    shellcheck-sarif = callPackage ./pkgs/shellcheck-sarif.nix {inherit (final) shellcheck-sarif;};

    flat-manager = callPackage ./pkgs/flat-manager.nix {inherit (final) flat-manager;};
    flat-manager-client = callPackage ./pkgs/flat-manager-client.nix {inherit (final) flat-manager;};

    klassy = prev.libsForQt5.callPackage ./pkgs/klassy.nix {};

    modrinth-app-unwrapped = callPackage ./pkgs/modrinth-app-unwrapped/package.nix {inherit (final) modrinth-app-unwrapped;};
    modrinth-app = callPackage ./pkgs/modrinth-app.nix {inherit (final) modrinth-app-unwrapped;};

    papa = callPackage ./pkgs/papa/package.nix {inherit (final) papa;};
  }

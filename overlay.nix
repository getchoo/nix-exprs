final: prev: let
  inherit (prev) lib callPackage;

  # use `callPackage` on all expressions in a directory
  pkgsFrom = dir:
    lib.mapAttrs' (
      name: _:
        lib.nameValuePair (lib.removeSuffix ".nix" name) (callPackage "${dir}/${name}" {})
    ) (builtins.readDir dir);
in
  pkgsFrom ./pkgs
  // {
    clang-tidy-sarif = callPackage ./pkgs/clang-tidy-sarif.nix {inherit (final) clang-tidy-sarif;};
    clippy-sarif = callPackage ./pkgs/clippy-sarif.nix {inherit (final) clippy-sarif;};
    hadolint-sarif = callPackage ./pkgs/hadolint-sarif.nix {inherit (final) hadolint-sarif;};
    sarif-fmt = callPackage ./pkgs/sarif-fmt.nix {inherit (final) sarif-fmt;};
    shellcheck-sarif = callPackage ./pkgs/shellcheck-sarif.nix {inherit (final) shellcheck-sarif;};

    klassy = prev.libsForQt5.callPackage ./pkgs/klassy.nix {};

    modrinth-app-unwrapped = callPackage ./pkgs/modrinth-app {
      inherit (final.nodePackages) pnpm;

      inherit
        (final.darwin.apple_sdk.frameworks)
        AppKit
        CoreServices
        Security
        WebKit
        ;
    };

    modrinth-app = callPackage ./pkgs/modrinth-app/wrapper.nix {
      inherit (final) modrinth-app-unwrapped;
    };
  }

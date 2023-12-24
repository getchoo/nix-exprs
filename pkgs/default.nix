final: prev:
with prev; let
  # files/directories are mapped to packages here for convenience sake
  imported = lib.pipe ./. [
    builtins.readDir

    (
      lib.filterAttrs (
        name: _: !(lib.hasPrefix "_" name) && name != "default.nix"
      )
    )

    (
      lib.mapAttrs' (
        file: _: lib.nameValuePair (lib.removeSuffix ".nix" file) (callPackage ./${file} {})
      )
    )
  ];
in
  imported
  // {
    clang-tidy-sarif = callPackage ./clang-tidy-sarif.nix {inherit (final) clang-tidy-sarif;};
    clippy-sarif = callPackage ./clippy-sarif.nix {inherit (final) clippy-sarif;};
    hadolint-sarif = callPackage ./hadolint-sarif.nix {inherit (final) hadolint-sarif;};
    sarif-fmt = callPackage ./sarif-fmt.nix {inherit (final) sarif-fmt;};
    shellcheck-sarif = callPackage ./shellcheck-sarif.nix {inherit (final) shellcheck-sarif;};

    klassy = libsForQt5.callPackage ./klassy.nix {};

    modrinth-app-unwrapped = callPackage ./modrinth-app {
      inherit (final.nodePackages or prev.nodePackages) pnpm;

      inherit
        ((final.darwin or prev.darwin).apple_sdk.frameworks)
        AppKit
        CoreServices
        Security
        WebKit
        ;
    };

    modrinth-app = callPackage ./modrinth-app/wrapper.nix {
      inherit (final) modrinth-app-unwrapped;
    };
  }

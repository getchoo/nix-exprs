final: prev:
with prev; let
  # directories are mapped to packages here for convenience sake
  imported = lib.pipe ./. [
    builtins.readDir

    (
      lib.filterAttrs (
        name: type: !(lib.hasPrefix "_" name) && type == "directory"
      )
    )

    (
      lib.mapAttrs (
        file: _: callPackage ./${file} {}
      )
    )
  ];
in
  imported
  // {
    clang-tidy-sarif = callPackage ./clang-tidy-sarif {inherit (final) clang-tidy-sarif;};
    clippy-sarif = callPackage ./clippy-sarif {inherit (final) clippy-sarif;};
    hadolint-sarif = callPackage ./hadolint-sarif {inherit (final) hadolint-sarif;};
    sarif-fmt = callPackage ./sarif-fmt {inherit (final) sarif-fmt;};

    klassy = libsForQt5.callPackage ./klassy {};

    modrinth-app-unwrapped = callPackage ./modrinth-app {
      inherit (final.nodePackages or prev.nodePackages) pnpm;
      inherit ((final.darwin or prev.darwin).apple_sdk.frameworks) CoreServices Security WebKit;
    };

    modrinth-app = callPackage ./modrinth-app/wrapper.nix {
      inherit (final) modrinth-app-unwrapped;
    };
  }

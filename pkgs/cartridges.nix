{
  blueprint-compiler,
  desktop-file-utils,
  fetchFromGitHub,
  fetchFromGitLab,
  gobject-introspection,
  lib,
  libadwaita,
  meson,
  ninja,
  python3,
  stdenv,
  wrapGAppsHook4,
  ...
}: let
  inherit (lib) licenses platforms;

  # it seems cartridges uses features only available in newer versions of
  # blueprint-compiler
  blueprint-compiler' = blueprint-compiler.overrideAttrs (_: rec {
    version = "0.8.1";
    src = fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "jwestman";
      repo = "blueprint-compiler";
      rev = "v${version}";
      hash = "sha256-3lj9BMN5aNujbhhZjObdTOCQfH5ERQCgGqIAw5eZIQc=";
    };

    doCheck = false;
  });
in
  stdenv.mkDerivation rec {
    pname = "cartridges";
    version = "1.5.6";

    src = fetchFromGitHub {
      owner = "kra-mo";
      repo = "cartridges";
      rev = "v${version}";
      sha256 = "sha256-Nog3EBfA7WwHKqclijNtaN3NSeggf3G4/BLqArl6JWM=";
    };

    buildInputs = [
      gobject-introspection
      libadwaita
      (python3.withPackages (p:
        with p; [
          pillow
          pygobject3
          pyyaml
          requests
        ]))
    ];

    nativeBuildInputs = [
      blueprint-compiler'
      desktop-file-utils
      meson
      ninja
      wrapGAppsHook4
    ];

    meta = {
      description = "A GTK4 + Libadwaita game launcher";
      longDescription = ''
        A simple game launcher for all of your games.
        It has support for importing games from Steam, Lutris, Heroic
        and more with no login necessary.
        You can sort and hide games or download cover art from SteamGridDB.
      '';
      homepage = "https://apps.gnome.org/app/hu.kramo.Cartridges/";
      license = licenses.gpl3Plus;
      #maintainers = [maintainers.getchoo];
      platforms = platforms.linux;
    };
  }

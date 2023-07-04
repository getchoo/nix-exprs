{
  lib,
  dbus,
  freetype,
  fetchFromGitHub,
  flite,
  glfw,
  glib-networking,
  gtk3,
  jdk8,
  jdk17,
  jdks ? [jdk8 jdk17],
  libappindicator-gtk3,
  libGL,
  libpulseaudio,
  librsvg,
  libsoup,
  mkYarnPackage,
  openal,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  webkitgtk,
  wrapGAppsHook,
  xorg,
  ...
}: let
  pname = "theseus";

  src = fetchFromGitHub {
    owner = "modrinth";
    repo = "theseus";
    rev = "6650cc9ce431b61b5c9a9bf7361b47e4e0e6facf";
    sha256 = "sha256-lgOhyV6wj/hbRuTyRrtkBI+vD5RYfjZ7ezSzHVAqmzM=";
  };

  theseus-frontend = let
    source = src + "/theseus_gui";
  in
    mkYarnPackage {
      pname = "${pname}-frontend";

      src = source;

      packageJson = source + "/package.json";
      yarnLock = ./yarn.lock;

      buildPhase = ''
        export HOME=$(mktemp -d)
        yarn --offline run build
        cp -r deps/theseus_gui/dist $out
      '';

      distPhase = "true";
      dontInstall = true;
    };
in
  rustPlatform.buildRustPackage {
    inherit pname src;
    version = "2023-07-04";

    postPatch = ''
      substituteInPlace theseus_gui/src-tauri/tauri.conf.json \
        --replace '"distDir": "../dist",' '"distDir": "${theseus-frontend}",'
    '';

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
      outputHashes = {
        "tauri-plugin-single-instance-0.0.0" = "sha256-GkWRIVhiPGds5ocht1K0eetfeDCvyX4wRr1JheO7aik=";
      };
    };

    buildInputs = [
      dbus
      freetype
      gtk3
      libappindicator-gtk3
      librsvg
      libsoup
      openssl
      webkitgtk
    ];

    nativeBuildInputs = [
      pkg-config
      wrapGAppsHook
    ];

    preFixup = let
      libPath = lib.makeLibraryPath ([
          flite
          glfw
          libGL
          libpulseaudio
          openal
          stdenv.cc.cc.lib
        ]
        ++ (with xorg; [
          libX11
          libXcursor
          libXext
          libXxf86vm
          libXrandr
        ]));
      binPath = lib.makeBinPath ([xorg.xrandr] ++ jdks);
    in ''
      gappsWrapperArgs+=(
        --set LD_LIBRARY_PATH /run/opengl-driver/lib:${libPath}
       	--prefix GIO_MODULE_DIR : ${glib-networking}/lib/gio/modules/
        --prefix PATH : ${binPath}
      )
    '';

    meta = with lib; {
      description = "Modrinth's future game launcher";
      longDescription = ''
        Modrinth's future game launcher which can be used as a CLI, GUI, and a library for creating and playing Modrinth projects.
      '';
      homepage = "https://modrinth.com";
      license = licenses.gpl3Plus;
      maintainers = [maintainers.getchoo];
      platforms = with platforms; linux ++ darwin;
    };
  }

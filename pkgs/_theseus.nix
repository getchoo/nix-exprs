{
  lib,
  dbus,
  freetype,
  fetchFromGitHub,
  fetchYarnDeps,
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
  inherit (lib) licenses maintainers makeBinPath makeLibraryPath platforms;
  pname = "theseus";

  rev = "e0e9c3f1666d3db220cd8918acfa091ec4eecb36";
  src = fetchFromGitHub {
    owner = "modrinth";
    repo = "theseus";
    inherit rev;
    sha256 = "sha256-pIJQQAYSQBalW1pQBCirkcxmS6DBGj/E6zKL8/Nc8Ww=";
  };

  theseus-frontend = let
    source = src + "/theseus_gui";
  in
    mkYarnPackage {
      pname = "${pname}-frontend";

      src = source;

      offlineCache = fetchYarnDeps {
        yarnLock = source + "/yarn.lock";
        sha256 = "sha256-UFPILd1f4kp0VTPlBccp36kTpsHUrcsxkfHMCtaDX3Y=";
      };

      packageJson = source + "/package.json";

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
    version = builtins.substring 0 7 rev;

    postPatch = ''
      substituteInPlace theseus_gui/src-tauri/tauri.conf.json \
        --replace '"distDir": "../dist",' '"distDir": "${theseus-frontend}",'
    '';

    cargoSha256 = "sha256-xleTO3AEW3yfkfJY2XjJt8g1WotdaB3tW6u/naxDszE=";

    buildInputs = [
      dbus
      freetype
      gtk3
      libappindicator-gtk3
      librsvg
      libsoup
      openssl
      webkitgtk
      wrapGAppsHook
    ];

    nativeBuildInputs = [pkg-config];

    preFixup = let
      libPath = makeLibraryPath ([
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
      binPath = makeBinPath ([xorg.xrandr] ++ jdks);
    in ''
      gappsWrapperArgs+=(
        --set LD_LIBRARY_PATH /run/opengl-driver/lib:${libPath}
       	--prefix GIO_MODULE_DIR : ${glib-networking}/lib/gio/modules/
        --prefix PATH : ${binPath}
      )

      runHook postInstall
    '';

    meta = {
      description = "Modrinth's future game launcher";
      longDescription = ''
        Modrinth's future game launcher which can be used as a CLI, GUI, and a library for creating and playing Modrinth projects.
      '';
      homepage = "https://modrinth.com";
      license = licenses.gpl3Plus;
      #maintainers = [maintainers.getchoo];
      platforms = with platforms; linux ++ darwin;
    };
  }

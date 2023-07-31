{
  lib,
  stdenv,
  stdenvNoCC,
  rustPlatform,
  buildGoModule,
  pnpm,
  esbuild,
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
  jq,
  libappindicator-gtk3,
  libGL,
  libpulseaudio,
  librsvg,
  libsoup,
  moreutils,
  openal,
  openssl,
  pkg-config,
  webkitgtk,
  wrapGAppsHook,
  xorg,
}:
rustPlatform.buildRustPackage rec {
  pname = "theseus";
  version = "unstable-2023-07-29";

  src = fetchFromGitHub {
    owner = "modrinth";
    repo = "theseus";
    rev = "87449f91c3d76dc784238fe8a30e6594c696e850";
    sha256 = "sha256-bPVOD8yQU/AmxZmOKawtPEPU7r7lBjS24cCDdL3yXnA=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "tauri-plugin-single-instance-0.0.0" = "sha256-G4h2OXKPpZMmradutdUWxGG5axL9XMz2ACAe8AQ40eg=";
    };
  };

  pnpm-deps = stdenvNoCC.mkDerivation {
    pname = "${pname}-pnpm-deps";
    inherit src version;

    nativeBuildInputs = [
      jq
      moreutils
      pnpm
    ];

    # https://github.com/NixOS/nixpkgs/blob/763e59ffedb5c25774387bf99bc725df5df82d10/pkgs/applications/misc/pot/default.nix#L56
    installPhase = ''
      export HOME=$(mktemp -d)

      cd theseus_gui
      pnpm config set store-dir $out
      pnpm install --frozen-lockfile --no-optional --ignore-script

      rm -rf $out/v3/tmp
      for f in $(find $out -name "*.json"); do
        sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
        jq --sort-keys . $f | sponge $f
      done
    '';

    dontFixup = true;
    outputHashMode = "recursive";
    outputHash = "sha256-058bnPV0p75IoW62F2jS9ofn49InSYqpDjU/gnGDjl8=";
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
    pnpm
    wrapGAppsHook
  ];

  ESBUILD_BINARY_PATH = "${lib.getExe (esbuild.override {
    buildGoModule = args:
      buildGoModule (args
        // rec {
          version = "0.17.19";
          src = fetchFromGitHub {
            owner = "evanw";
            repo = "esbuild";
            rev = "v${version}";
            hash = "sha256-PLC7OJLSOiDq4OjvrdfCawZPfbfuZix4Waopzrj8qsU=";
          };
          vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
        });
  })}";

  preBuild = ''
    export HOME=$(mktemp -d)
    export STORE_PATH=$(mktemp -d)
    pushd theseus_gui

    cp -r ${pnpm-deps}/* "$STORE_PATH"
    chmod -R +w "$STORE_PATH"

    pnpm config set store-dir "$STORE_PATH"
    pnpm install --offline --frozen-lockfile --no-optional --ignore-script
    pnpm build
		ls

    popd
  '';

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

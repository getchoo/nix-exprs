{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  rustPlatform,
  modrinth-app-unwrapped,
  cacert,
  cargo-tauri,
  desktop-file-utils,
  esbuild,
  darwin,
  jq,
  libsoup,
  moreutils,
  nodePackages,
  openssl,
  pkg-config,
  webkitgtk,
}:
rustPlatform.buildRustPackage {
  pname = "modrinth-app-unwrapped";
  version = "unstable-2024-04-07";

  src = fetchFromGitHub {
    owner = "modrinth";
    repo = "theseus";
    rev = "3e7fd808248003cf87ced405ba7c1d536b596f97";
    hash = "sha256-W6o0EQLouMU0/NhELa2VL2s75dzzqHgVTxlhR6zwy5g=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "tauri-plugin-single-instance-0.0.0" = "sha256-f3CxIg42zsGFG4qxpKklxXh48UVuK9xB+VrNICizcx4=";
    };
  };

  nativeBuildInputs = [
    cargo-tauri
    desktop-file-utils
    nodePackages.pnpm
    pkg-config
  ];

  buildInputs =
    [openssl]
    ++ lib.optionals stdenv.isLinux [
      libsoup
      webkitgtk
    ]
    ++ lib.optionals stdenv.isDarwin (
      with darwin.apple_sdk.frameworks; [
        AppKit
        CoreServices
        Security
        WebKit
      ]
    );

  env = {
    tauriBundle =
      {
        Linux = "deb";
        Darwin = "app";
      }
      .${stdenv.hostPlatform.uname.system}
      or (builtins.throw "No tauri bundle available for ${stdenv.hostPlatform.uname.system}!");

    pnpmDeps = stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "${modrinth-app-unwrapped.pname}-pnpm-deps";
      inherit (modrinth-app-unwrapped) version src;
      sourceRoot = "${finalAttrs.src.name}/theseus_gui";

      dontConfigure = true;
      dontBuild = true;
      doCheck = false;

      nativeBuildInputs = [
        cacert
        jq
        moreutils
        nodePackages.pnpm
      ];

      env.pnpmPatch = builtins.toJSON {
        pnpm.supportedArchitectures = {
          # not all of these systems are supported yet,
          # but this should future proof things for a bit
          os = [
            "linux"
            "darwin"
          ];
          cpu = [
            "x64"
            "arm64"
          ];
        };
      };

      postPatch = ''
        mv package.json{,.orig}
        jq --raw-output ". * $pnpmPatch" package.json.orig > package.json
      '';

      # https://github.com/NixOS/nixpkgs/blob/763e59ffedb5c25774387bf99bc725df5df82d10/pkgs/applications/misc/pot/default.nix#L56
      installPhase = ''
        export HOME=$(mktemp -d)

        pnpm config set store-dir "$out"
        pnpm install --frozen-lockfile --no-optional --ignore-script

        # remove timestamp and sort json files
        rm -rf "$out"/v3/tmp
        for f in $(find "$out" -name "*.json"); do
          sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
          jq --sort-keys . "$f" | sponge "$f"
        done
      '';

      dontFixup = true;
      outputHashMode = "recursive";
      outputHash = "sha256-p6eZuuGgBPVhcfI50fMo22vpnzoWEhPI7IagowmhTCk=";
    });

    ESBUILD_BINARY_PATH = lib.getExe (
      esbuild.overrideAttrs (final:
        lib.const {
          version = "0.17.19";
          src = fetchFromGitHub {
            owner = "evanw";
            repo = "esbuild";
            rev = "v${final.version}";
            hash = "sha256-PLC7OJLSOiDq4OjvrdfCawZPfbfuZix4Waopzrj8qsU=";
          };
          vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";
        })
    );
  };

  postPatch = ''
    export HOME=$(mktemp -d)
    export STORE_PATH=$(mktemp -d)

    pushd theseus_gui
    cp -r "$pnpmDeps"/* "$STORE_PATH"
    chmod -R +w "$STORE_PATH"

    pnpm config set store-dir "$STORE_PATH"
    pnpm install --offline --frozen-lockfile --ignore-script
    popd
  '';

  buildPhase = ''
    runHook preBuild

    cargo tauri build --bundles "$tauriBundle"

    runHook postBuild
  '';

  installPhase =
    ''
      runHook preInstall
    ''
    + lib.optionalString stdenv.isDarwin ''
      mkdir -p "$out"/bin
      cp -r target/release/bundle/macos "$out"/Applications
      mv "$out"/Applications/Modrinth\ App.app/Contents/MacOS/Modrinth\ App "$out"/bin/modrinth-app
      ln -s "$out"/bin/modrinth-app "$out"/Applications/Modrinth\ App.app/Contents/MacOS/Modrinth\ App
    ''
    + lib.optionalString stdenv.isLinux ''
      cp -r target/release/bundle/"$tauriBundle"/*/data/usr "$out"
      desktop-file-edit \
        --set-comment "Modrinth's game launcher" \
        --set-key="StartupNotify" --set-value="true" \
        --set-key="Categories" --set-value="Game;ActionGame;AdventureGame;Simulation;" \
        --set-key="Keywords" --set-value="game;minecraft;mc;" \
        --set-key="StartupWMClass" --set-value="ModrinthApp" \
        $out/share/applications/modrinth-app.desktop
    ''
    + ''
      runHook postInstall
    '';

  meta = with lib; {
    mainProgram = "modrinth-app";
    description = "Modrinth's game launcher";
    longDescription = ''
      A unique, open source launcher that allows you to play your favorite mods,
      and keep them up to date, all in one neat little package
    '';
    homepage = "https://modrinth.com";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [getchoo];
    platforms = platforms.linux ++ platforms.darwin;
    # this builds on architectures like aarch64, but the launcher itself does not support them yet
    broken = !stdenv.isx86_64;
  };
}

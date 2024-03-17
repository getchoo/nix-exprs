{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  wrapGAppsHook,
  flightcore,
  cargo-tauri,
  glib,
  glib-networking,
  libsoup,
  nodejs,
  openssl,
  pkg-config,
  webkitgtk,
}:
rustPlatform.buildRustPackage {
  pname = "flightcore";
  version = "2.19.2";

  src = fetchFromGitHub {
    owner = "R2NorthstarTools";
    repo = "FlightCore";
    rev = "v${flightcore.version}";
    hash = "sha256-Gar6qCtnk3eUGhSjRHFx7aclPPaMCL+5CV30pCMsgvA=";
  };

  prePatch = ''
    pushd $npmRoot

    ln -sf ${./package.json} package.json
    ln -sf ${./package-lock.json} package-lock.json
    substituteInPlace $(find -type f -name '*.vue' -or -name '*.ts') \
      --replace "tauri-plugin-store-api" "@tauri-apps/plugin-store"

    popd
  '';

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "tauri-plugin-store-0.1.0" = "sha256-G7b1cIMr7YcI5cUhlYi4vhLFCe3/CMSPSB4gYY1Ynz8=";
    };
  };
  buildAndTestSubdir = flightcore.cargoRoot;
  cargoRoot = "src-tauri";

  npmDeps = fetchNpmDeps {
    name = "${flightcore.pname}-npm-deps-${flightcore.version}";
    src = ./.;
    hash = "sha256-2X5pZ0T1dR6NCB0qcSvQl0RsMA7KFYKUUI5Z8tQ7ddQ=";
  };

  npmRoot = "src-vue";
  makeCacheWritable = true;

  nativeBuildInputs = [
    cargo-tauri
    nodejs
    npmHooks.npmConfigHook
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    glib
    glib-networking
    libsoup
    openssl
    webkitgtk
  ];

  buildPhase = ''
    runHook preBuild

    cargo tauri build --bundles deb

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r ${flightcore.cargoRoot}/target/release/bundle/deb/*/data/usr $out

    runHook postInstall
  '';

  meta = with lib; {
    mainProgram = "flight-core";
    description = "A Northstar installer, updater, and mod-manager";
    homepage = "https://github.com/R2NorthstarTools/FlightCore";
    changelog = "https://github.com/R2NorthstarTools/FlightCore/releases/tag/v${flightcore.version}";
    license = licenses.mit;
    maintainers = with maintainers; [getchoo];
  };
}

{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  testers,
  papa,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage {
  pname = "papa";
  version = "4.1.0-rc.3";

  src = fetchFromGitHub {
    owner = "AnActualEmerald";
    repo = "papa";
    rev = "v${papa.version}";
    hash = "sha256-opuBCuc3YCAdwwg6XbTX0HRrV3FsVdJStEACMvtTM1w=";
  };

  postUnpack = ''
    rmdir source/thermite
    ln -sf ${papa.libthermite} source/thermite
  '';

  postPatch = ''
    ln -sf ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [pkg-config installShellFiles];
  buildInputs = [openssl];

  postInstall = ''
    installShellCompletion --cmd papa \
      --bash <($out/bin/papa complete bash) \
      --fish <($out/bin/papa complete fish) \
      --zsh <($out/bin/papa complete zsh)
  '';

  passthru = {
    tests.version = testers.testVersion {package = papa;};

    updateScript = nix-update-script {};

    libthermite = fetchFromGitHub {
      owner = "AnActualEmerald";
      repo = "thermite";
      rev = "8e6fc6af20e9bd2af4313fee65dfed05cfa1bbd5";
      hash = "sha256-7zkXW2G7cwyobYJO22o1QoJRs2O6sD7/S9frZ/+DNIQ=";
    };
  };

  meta = with lib; {
    mainProgram = "papa";
    description = "Mod manager for Northstar clients and servers";
    homepage = "https://github.com/AnActualEmerald/papa";
    changelog = "https://github.com/AnActualEmerald/papa/releases/tag/v${papa.version}";
    license = licenses.mit;
    maintainers = with maintainers; [getchoo];
    platforms = platforms.unix;
  };
}

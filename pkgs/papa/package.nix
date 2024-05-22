{
  lib,
  rustPlatform,
  fetchFromGitHub,
  papa,
  installShellFiles,
  nix-update-script,
  testers,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "papa";
  version = "4.1.0-rc.4";

  src = fetchFromGitHub {
    owner = "AnActualEmerald";
    repo = "papa";
    rev = "v${version}";
    hash = "sha256-XAYenoWLKeNzNozFRPz84WDeU0/y2hd/wgr3UeZLFS0=";
  };

  postUnpack = ''
    rmdir source/thermite
    ln -sf ${passthru.libthermite} source/thermite
  '';

  cargoHash = "sha256-t2c/eaQLEKLzJEvyY35Kithon5K5Bes3OWmQgExigzI=";

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
    description = "Mod manager for Northstar clients and servers";
    homepage = "https://github.com/AnActualEmerald/papa";
    changelog = "https://github.com/AnActualEmerald/papa/releases/tag/v${src.version}";
    mainProgram = "papa";
    license = licenses.mit;
    maintainers = with maintainers; [getchoo];
    platforms = platforms.unix;
  };
}

{
  lib,
  rustPlatform,
  fetchFromGitHub,
  flat-manager,
  glib,
  openssl,
  ostree,
  postgresql,
  pkg-config,
}:
rustPlatform.buildRustPackage {
  pname = "flat-manager";
  version = "unstable-2024-01-20";

  src = fetchFromGitHub {
    owner = "flatpak";
    repo = flat-manager.pname;
    rev = "d1c3d36da7b5779163ff70007c4d2f145cfce664";
    hash = "sha256-Gt3c+fIC0W6+OJ4m6ujmS1nB9Nnr39oHlzxaKCxGAag=";
  };

  cargoHash = "sha256-xdJYSVH7l31/LpgS615D7kcvjxILFPMiVWDDvmm/3VE=";

  nativeBuildInputs = [pkg-config];
  buildInputs = [glib openssl ostree postgresql];

  meta = with lib; {
    mainProgram = "flat-manager";
    description = "Manager for flatpak repositories";
    longDescription = ''
      flat-manager serves and maintains a Flatpak repository. You point it at an ostree
      repository and it will allow Flatpak clients to install apps from the repository over HTTP.
      Additionally, it has an HTTP API that lets you upload new builds and manage the repository.
    '';
    homepage = "https://github.com/flatpak/flat-manager";
    changelog = "https://github.com/flatpak/flat-manager/releases/tag/${flat-manager.version}";
    maintainers = with maintainers; [getchoo];
    platforms = platforms.linux;
  };
}

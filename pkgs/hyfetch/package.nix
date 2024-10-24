{
  lib,
  fastfetch,
  fetchFromGitHub,
  installShellFiles,
  macchina,
  makeBinaryWrapper,
  neowofetch,
  rustPlatform,
  unstableGitUpdater,
  withAutocomplete ? true,
  withColor ? true,
  withFastfetch ? true,
  withMacchina ? true,
}:

let
  binPath = [
    neowofetch
  ] ++ lib.optional withFastfetch fastfetch ++ lib.optional withMacchina macchina;
in
rustPlatform.buildRustPackage rec {
  pname = "hyfetch";
  version = "1.99.0-unstable-2024-10-23";

  src = fetchFromGitHub {
    owner = "hykilpikonna";
    repo = "hyfetch";
    rev = "b5b49ecbc095ac20e49c0783121c885752df9001";
    hash = "sha256-W1oMzLACGDvcl8du4L3TuUn79i6HFUFuPEJhc3IPD0E=";
  };

  # https://github.com/hykilpikonna/hyfetch/pull/361
  #
  # Upstream will call `neowofetch` with Bash (from the PATH) by default
  # We know `neowofetch` has a shebang though, so run it directly to avoid
  # adding Bash to the wrapper
  #
  # Yes, this introduces 2 warnings
  postPatch = ''
    substituteInPlace crates/hyfetch/src/neofetch_util.rs \
      --replace-fail 'command.arg(neofetch_path)' 'let mut command = Command::new(neofetch_path)'
  '';

  cargoHash = "sha256-4Tz6hqzjlCT5PSa1AzWGU6mBHWxMcsJm9+Uzmsvurps=";

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ];

  cargoBuildNoDefaultFeatures = true;
  cargoBuildFeatures =
    lib.optional withAutocomplete "autocomplete"
    ++ lib.optional withColor "color"
    ++ lib.optional withMacchina "macchina";

  cargoBuildFlags = [ "--package hyfetch" ];
  cargoTestFlags = cargoBuildFlags;

  postInstall = ''
    installManPage docs/hyfetch.1
  '';

  postFixup = ''
    wrapProgram "$out"/bin/hyfetch \
      --prefix PATH : ${lib.makeBinPath binPath}
  '';

  passthru = {
    updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "neofetch with pride flags <3";
    longDescription = ''
      HyFetch is a command-line system information tool fork of neofetch.
      HyFetch displays information about your system next to your OS logo
      in ASCII representation. The ASCII representation is then colored in
      the pattern of the pride flag of your choice. The main purpose of
      HyFetch is to be used in screenshots to show other users what
      operating system or distribution you are running, what theme or
      icon set you are using, etc.
    '';
    homepage = "https://github.com/hykilpikonna/HyFetch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ getchoo ];
    mainProgram = "hyfetch";
  };
}

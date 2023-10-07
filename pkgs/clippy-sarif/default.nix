{
  lib,
  fetchFromGitHub,
  rustPlatform,
  clippy,
}:
rustPlatform.buildRustPackage rec {
  pname = "clippy-sarif";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "psastras";
    repo = "sarif-rs";
    rev = "${pname}-v${version}";
    hash = "sha256-EzWzDeIeSJ11CVcVyAhMjYQJcKHnieRrFkULc5eXAno=";
  };

  cargoSha256 = "sha256-F3NrqkqLdvMRIuozCMMqwlrrf5QrnmcEhy4TGSzPhiU=";
  cargoBuildFlags = ["--package ${pname}"];

  doCheck = false;

  meta = with lib; {
    description = "CLI tool to convert clippy diagnostics into SARIF";
    homepage = "https://github.com/psastras/sarif-rs";
    maintainers = with maintainers; [getchoo];
    license = licenses.mit;
    inherit (clippy.meta) platforms;
  };
}

{
  lib,
  fetchFromGitHub,
  rustPlatform,
  clippy,
}:
rustPlatform.buildRustPackage rec {
  pname = "clippy-sarif";
  version = "0.4.1";

  src = lib.cleanSource (fetchFromGitHub {
    owner = "psastras";
    repo = "sarif-rs";
    rev = "${pname}-v${version}";
    hash = "sha256-TnH2GQ8uComMgeUk7i63KA3hbWC/5KuLxoRXlR8qlVs=";
  });

  cargoSha256 = "sha256-Y0n0GfUguqdTdZO6SyWNysv3IlXiKqhSiiHxxUEUZo8=";
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

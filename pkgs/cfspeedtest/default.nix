{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "cfspeedtest";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "code-inflation";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ZbE8/mh9hb81cGz0Wxq3gTa9BueKfQApeq5z2DGUak0=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  meta = with lib; {
    homepage = "https://github.com/code-inflation/cfspeedtest";
    description = "Unofficial CLI for speed.cloudflare.com";
    license = licenses.mit;
    maintainers = with maintainers; [getchoo];
  };
}

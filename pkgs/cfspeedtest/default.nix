{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "cfspeedtest";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "code-inflation";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-YF/jf1TzNW1QswNefQ4qKeXDyjFoN9/AWcjoeENCgvc=";
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

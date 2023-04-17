{
  lib,
  fetchFromGitHub,
  polkit,
  rustPlatform,
  xorg,
}: let
  inherit (rustPlatform) buildRustPackage;
  inherit (lib) licenses maintainers platforms;
in
  buildRustPackage rec {
    pname = "swhkd";
    version = "1.2.1";

    src = fetchFromGitHub {
      owner = "waycrate";
      repo = "swhkd";
      rev = version;
      sha256 = "sha256-VQW01j2RxhLUx59LAopZEdA7TyZBsJrF1Ym3LumvFqA=";
    };

    cargoPatches = [
      ./update-lock.patch
    ];
    cargoSha256 = "sha256-h8n4qB6n4et7d1CfIwam8y9A1gH9lsqZD50t9YI1ieM=";

    buildInputs = [
      polkit
      xorg.xf86inputevdev
    ];

    meta = {
      description = "Sxhkd clone for Wayland";
      longDescription = "a display protocol-independent hotkey daemon made in Rust";
      homepage = "https://github.com/waycrate/swhkd";
      license = licenses.bsd2;
      maintainers = with maintainers; [getchoo];
      platforms = platforms.linux;
    };
  }

{
  lib,
  callPackage,
  fetchFromGitHub,
  naersk,
  polkit,
  xorg,
}: let
  version = "1.2.1";
  package = (callPackage naersk {}).buildPackage {
    buildInputs = [
      polkit
      xorg.xf86inputevdev
    ];
    src = fetchFromGitHub {
      owner = "waycrate";
      repo = "swhkd";
      rev = version;
      sha256 = "sha256-VQW01j2RxhLUx59LAopZEdA7TyZBsJrF1Ym3LumvFqA=";
    };
  };
in
  package
  // (let
    inherit (lib) licenses maintainers platforms;
  in {
    meta =
      package.meta
      // {
        description = "Sxhkd clone for Wayland";
        longDescription = "a display protocol-independent hotkey daemon made in Rust";
        homepage = "https://github.com/waycrate/swhkd";
        license = licenses.bsd2;
        maintainers = with maintainers; [getchoo];
        platforms = platforms.linux;
      };
  })

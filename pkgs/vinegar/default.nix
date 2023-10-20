{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  libglvnd,
  libxkbcommon,
  pkg-config,
  vulkan-headers,
  wayland,
  wayland-protocols,
  wine,
  winetricks,
  xorg,
}:
buildGoModule rec {
  pname = "vinegar";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "vinegarhq";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-H7aANwVmeCnOIsN4/cAog7Bik3jEZo5ytgVSCmI7hpg=";
  };

  vendorHash = "sha256-7SWyzEPQgkwgsrG3GbDXN3tc0ZLWv7vw/SNVb3eaziY=";

  buildInputs = [
    libglvnd
    libxkbcommon
    wayland
    wayland-protocols
    vulkan-headers
    xorg.libX11
    xorg.libXfixes
    xorg.libXcursor
  ];

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  postFixup = ''
    wrapProgram "$out/bin/vinegar" \
      --prefix PATH : ${lib.makeBinPath [wine winetricks]}
  '';

  meta = with lib; {
    homepage = "https://vinegarhq.github.io/";
    description = "A wrapper for Roblox with many advanced optimization features.";
    longDescription = ''
      Vinegar is a wrapper for Roblox that includes various optimization and ease-of-use features, including the RCO FFlag set, fast launching, and more.
    '';
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [getchoo];
    platforms = ["x86_64-linux"];
  };
}

{
  lib,
  stdenv,
  ensureNewerSourcesForZipFilesHook,
  fetchFromGitHub,
  fontconfig,
  freetype,
  libopus,
  pkg-config,
  python3,
  SDL2,
  waf,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xash3d";
  version = "unstable-2024-01-15";

  src = fetchFromGitHub {
    owner = "FWGS";
    repo = "xash3d-fwgs";
    rev = "40041e30eb0dd93b6484c2b0057b21e3b70c15e3";
    hash = "sha256-6d5b4eewZIyk5ybhVIwrAslEnSKnPKqjWlvQWeMM1zU=";
    fetchSubmodules = true;
  };

  preConfigure = ''
    rm -rf 3rdparty/opus/opus
    ln -s ${libopus.src} 3rdparty/opus/opus
  '';

  buildInputs = [
    fontconfig
    freetype
    SDL2
    libopus
  ];

  nativeBuildInputs = [
    pkg-config
    python3
    ensureNewerSourcesForZipFilesHook
    waf.hook
  ];

  wafInstallFlags = "--destdir=/";

  meta = with lib; {
    description = "A game engine aimed to provide compatibility with Half-Life Engine and extend it";
    longDescription = ''
      Xash3D FWGS is a game engine, aimed to provide compatibility with Half-Life Engine and extend it, as well as to give game developers well known workflow.

      Xash3D FWGS is a heavily modified fork of an original Xash3D Engine by Unkle Mike.
    '';
    homepage = "https://github.com/FWGS/xash3d-fwgs";
    # this has a lot of licensing issues...best to play it safe
    # see https://github.com/FWGS/xash3d-fwgs/issues/63
    license = with licenses; unfree;
    maintainers = with maintainers; [getchoo];
    platforms = ["x86_64-linux" "i686-linux"];
  };
})

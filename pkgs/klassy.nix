{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  extra-cmake-modules,
  kcmutils,
  kdecoration,
  kirigami2,
  wrapQtAppsHook,
}:
stdenv.mkDerivation rec {
  name = "klassy";
  version = "4.3.breeze5.27.5";

  src = fetchFromGitHub {
    owner = "paulmcauley";
    repo = "klassy";
    rev = version;
    hash = "sha256-2qs30L7U5kf1Yf+4Pgsjsyaqf9iIaeuRK25Xtn47AYI=";
  };

  buildInputs = [
    kcmutils
    kdecoration
    kirigami2
  ];

  nativeBuildInputs = [
    cmake
    ninja
    extra-cmake-modules
    wrapQtAppsHook
  ];

  meta = with lib; {
    description = "a highly customizable binary Window Decoration and Application Style plugin";
    longDescription = ''
      Klassy is a highly customizable binary Window Decoration and Application
      Style plugin for recent versions of the KDE Plasma desktop. It provides
      the Klassy, Kite, Oxygen/Breeze, and Redmond icon styles.
    '';
    homepage = "https://github.com/paulmcauley/klassy";
    platforms = platforms.linux;
    maintainers = with maintainers; [getchoo];
  };
}

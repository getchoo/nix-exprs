{
  lib,
  cmake,
  extra-cmake-modules,
  fetchFromGitLab,
  libsForQt5,
  ninja,
  pkg-config,
  stdenv,
  xorg,
}:
stdenv.mkDerivation rec {
  pname = "xwaylandvideobridge";
  version = "unstable-2023-09-11";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = pname;
    rev = "b9e0c53570f55f4e8289f72ba78f3945e27e1a1a";
    sha256 = "sha256-tnWfpx/6aABe0VdIjOtx3oDL8C4uQo0yTd6VbAQT7/o=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    ninja
    libsForQt5.qt5.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = with libsForQt5; [
    kcoreaddons
    kdbusaddons
    ki18n
    knotifications
    kpipewire
    kwidgetsaddons
    kwindowsystem
    qt5.qtquickcontrols2
    qt5.qtx11extras
    xorg.libxcb
  ];

  meta = with lib; {
    description = "Utility to allow streaming Wayland windows to X applications";
    homepage = "https://invent.kde.org/system/xwaylandvideobridge";
    license = licenses.gpl2Plus;
    maintainer = [maintainers.getchoo];
    platforms = platforms.linux;
  };
}

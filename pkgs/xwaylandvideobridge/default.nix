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
  version = "unstable-2023-10-06";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = pname;
    rev = "4941030dffac94b9c04398490911482ed2b564f3";
    sha256 = "sha256-JRdzy71r3mJQybmbCooXfsJRyvLBAsOKsAtcjVvKEag=";
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

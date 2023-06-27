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
}: let
  kpipewire' = libsForQt5.kpipewire.overrideAttrs (prev: {
    version = "5.27";

    src = fetchFromGitLab {
      domain = "invent.kde.org";
      owner = "plasma";
      repo = prev.pname;
      rev = "Plasma/5.27";
      sha256 = "sha256-3PMmfb074an9vx7VdpOWpD5gVNAUp7XipZz1Xgz0To8=";
    };
  });
in
  stdenv.mkDerivation rec {
    pname = "xwaylandvideobridge";
    version = "2023-06-27-unstable";

    src = fetchFromGitLab {
      domain = "invent.kde.org";
      owner = "system";
      repo = pname;
      rev = "a9c40f8cda1016d20cea80ecdbfc90637c6f24dd";
      sha256 = "sha256-COv3lQuJ4LO6iThAy9lrfYPKkZTkiVSvqBp2xzPHKKw=";
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
      kpipewire'
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

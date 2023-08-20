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
      sha256 = "sha256-u+CGk/jm5pHTPJYwKHwHc01c9E+ElsfKkzYg5NfIaJ8=";
    };
  });
in
  stdenv.mkDerivation rec {
    pname = "xwaylandvideobridge";
    version = "unstable-2023-08-20";

    src = fetchFromGitLab {
      domain = "invent.kde.org";
      owner = "system";
      repo = pname;
      rev = "4555293e49129dcb5f8c3354c86b29d561ca4034";
      sha256 = "sha256-YtFcf43DQy7ImFYYQ45ELPRdFYVrBkpL/Bam8SUEVfE=";
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

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
    version = "unstable-2023-07-26";

    src = fetchFromGitLab {
      domain = "invent.kde.org";
      owner = "system";
      repo = pname;
      rev = "014111b4db6298968204fd56d5ce6f691137bf90";
      sha256 = "sha256-6ro5Y5GSiodzbsiPQls4IAOYGLcLE7j+0eumpW6+HeU=";
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

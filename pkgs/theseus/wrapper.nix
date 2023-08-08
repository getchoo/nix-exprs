{
  lib,
  stdenv,
  symlinkJoin,
  theseus-unwrapped,
  wrapGAppsHook,
  dbus,
  flite,
  freetype,
  glib-networking,
  glfw,
  gtk3,
  jdk8,
  jdk17,
  jdks ? [jdk8 jdk17],
  libappindicator-gtk3,
  libGL,
  libpulseaudio,
  librsvg,
  libsoup,
  openal,
  webkitgtk,
  xorg,
  ...
}: let
  theseusFinal = theseus-unwrapped;
in
  symlinkJoin {
    name = "theseus-${theseusFinal.version}";

    paths = [theseusFinal];

    nativeBuildInputs = [
      wrapGAppsHook
    ];

    buildInputs = lib.optionals stdenv.isLinux [
      dbus
      freetype
      gtk3
      libappindicator-gtk3
      librsvg
      libsoup
      webkitgtk
    ];

    preFixup = let
      libPath = lib.makeLibraryPath ([
          flite
          glfw
          libGL
          libpulseaudio
          openal
          stdenv.cc.cc.lib
        ]
        ++ (with xorg; [
          libX11
          libXcursor
          libXext
          libXxf86vm
          libXrandr
        ]));
      binPath = lib.makeBinPath (lib.optionals stdenv.isLinux [xorg.xrandr] ++ jdks);
    in ''
      gappsWrapperArgs+=(
        ${lib.optionalString stdenv.isLinux "--set LD_LIBRARY_PATH /run/opengl-driver/lib:${libPath}"}
        ${lib.optionalString stdenv.isLinux "--prefix GIO_MODULE_DIR : ${glib-networking}/lib/gio/modules/"}
        --prefix PATH : ${binPath}
      )
    '';

    inherit (theseusFinal) meta;
  }

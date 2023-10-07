{
  lib,
  stdenv,
  autoPatchelfHook,
  dpkg,
  dbus,
  fetchurl,
  freetype,
  fontconfig,
  libusb1,
  glib,
  krb5,
  libsForQt5,
  makeWrapper,
  mesa,
  systemd,
  xkbd,
  xorg,
  zlib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "huion-g930l-driver";
  version = "15.0.0.103";

  src = fetchurl {
    url = "https://driverdl.huion.com/driver/X10_G930L_Q630M/HuionTablet_v15.0.0.103.202208301443.x86_64.deb";
    sha256 = "sha256-xOefpUj6V/XvEmtl8ETkmZgLtlHSyRzsZSZfhkQFtsg=";
  };

  sourceRoot = ".";
  unpackCmd = "dpkg-deb -x $src .";

  nativeBuildInputs = [autoPatchelfHook dpkg makeWrapper];
  buildInputs =
    [
      dbus
      freetype
      fontconfig
      libusb1
      glib
      krb5
      mesa
      systemd
      xkbd
      xorg.libX11
      xorg.libxcb
      xorg.libXext
      xorg.libXrandr
      zlib
    ]
    ++ (with libsForQt5; [
      qt5.qtbase
      qt5.qtgamepad
      qt5.qtvirtualkeyboard
      qt5.qtxmlpatterns
      qt3d
      qtquickcontrols
      qtquickcontrols2
    ]);

  dontWrapQtApps = true;
  # is this stupid? yes
  # i don't care
  autoPatchelfIgnoreMissingDeps = ["libQt5RemoteObjects.so.5"];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -R usr/{lib,share} $out/
    chmod -R g-w $out
    chmod 755 $out/lib/huiontablet/huiontablet.sh

    makeWrapper $out/lib/huiontablet/huiontablet.sh $out/bin/huiontablet \
      "''${qtappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

    substituteInPlace $out/share/applications/huiontablet.desktop \
      --replace /usr/lib/huiontablet/huiontablet.sh $out/bin/huiontablet \
      --replace /usr/share $out/share
  '';

  meta = {
    # this probably works but it hasn't been tested much so
    broken = true;
    description = "huion drivers for G930L";
    homepage = "https://www.huion.com/";
    maintainers = [lib.maintainers.getchoo];
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}

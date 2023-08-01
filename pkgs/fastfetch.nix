{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  chafa,
  cjson,
  dbus,
  dconf,
  glib,
  imagemagick,
  libGL,
  libnma,
  libpulseaudio,
  mesa,
  ocl-icd,
  opencl-headers,
  pciutils,
  vulkan-headers,
  wayland,
  xfce,
  xorg,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "fastfetch";
  version = "1.12.2";

  src = fetchFromGitHub {
    owner = "fastfetch-cli";
    repo = pname;
    rev = version;
    sha256 = "sha256-l9fIm7+dBsOqGoFUYtpYESAjDy3496rDTUDQjbNU4U0=";
  };

  cmakeFlags = ["-DCMAKE_INSTALL_SYSCONFDIR='etc'"];

  buildInputs = [
    chafa
    cjson
    dbus
    dconf
    glib
    imagemagick
    libnma
    libpulseaudio
    libGL
    mesa
    ocl-icd
    pciutils
    xfce.xfconf
    xorg.xrandr
    zlib
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    opencl-headers
    vulkan-headers
    xorg.libxcb
    xorg.libXrandr
    wayland
  ];

  postInstall = ''
    rm -rf $out/etc
  '';

  meta = with lib; {
    homepage = "https://github.com/fastfetch-cli/fastfetch";
    description = "Like neofetch, but much faster because written in C.";
    license = licenses.mit;
    platforms = with platforms; platforms.unix ++ platforms.windows;
    maintainers = with maintainers; [getchoo];
  };
}

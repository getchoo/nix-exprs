{
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  fetchFromGitHub,
  gnome,
  gnome-desktop,
  gobject-introspection,
  lib,
  libadwaita,
  libportal-gtk4,
  meson,
  ninja,
  python3Packages,
  stdenv,
  totem-pl-parser,
  wrapGAppsHook4,
  nix-update-script,
}:
stdenv.mkDerivation {
  pname = "hyperplane";
  version = "unstable-2023-12-17";

  src = fetchFromGitHub {
    owner = "kra-mo";
    repo = "hyperplane";
    rev = "f348c56e813083bcfb9ee993ad263c3f0068742e";
    hash = "sha256-cLgK7fnOXqNFvnS2Jl9EqRGhX5omw8R/1EJ6/1BEUYc=";
  };

  pythonPath = with python3Packages; [
    pygobject3
  ];

  buildInputs = [
    gnome-desktop
    libadwaita
    libportal-gtk4
    gnome.totem
    totem-pl-parser
    python3Packages.python
  ];

  nativeBuildInputs = [
    appstream
    blueprint-compiler
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    python3Packages.wrapPython
    wrapGAppsHook4
  ];

  dontWrapGApps = true;

  postFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    wrapPythonPrograms "$out/bin" "$out" "$pythonPath"
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = ["--version=branch"];
    };
  };

  meta = with lib; {
    description = "A non-hierarchical file manager";
    homepage = "https://github.com/kra-mo/hyperplane";
    license = licenses.gpl3Plus;
    maintainers = [maintainers.getchoo];
    platforms = platforms.linux;
  };
}

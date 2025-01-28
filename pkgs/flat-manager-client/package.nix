{
  flat-manager,
  gobject-introspection,
  ostree,
  python3,
  stdenvNoCC,
  wrapGAppsNoGuiHook,
}:

stdenvNoCC.mkDerivation {
  pname = "flat-manager-client";
  inherit (flat-manager) version src;

  nativeBuildInputs = [
    gobject-introspection
    python3
    python3.pkgs.wrapPython
    wrapGAppsNoGuiHook
  ];

  buildInputs = [ ostree ];

  propagatedBuildInputs = with python3.pkgs; [
    python

    aiohttp
    pygobject3
    tenacity
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 {,$out/bin/}flat-manager-client
    runHook postInstall
  '';

  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];

  postFixup = "wrapPythonPrograms";

  meta = {
    inherit (flat-manager.meta)
      homepage
      changelog
      maintainers
      platforms
      ;
    description = flat-manager.meta.description + " (Client)";
    mainProgram = "flat-manager-client";
  };
}

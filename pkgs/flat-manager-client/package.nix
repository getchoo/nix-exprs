{
  lib,
  stdenvNoCC,
  flat-manager,
  python3,
  ostree,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "flat-manager-client";
  inherit (flat-manager) version src;

  pythonPath = with python3.pkgs; [
    aiohttp
    pygobject3
    tenacity
  ];

  nativeBuildInputs = [ python3.pkgs.wrapPython ];
  buildInputs = [ (python3.withPackages (lib.const finalAttrs.pythonPath)) ];

  installPhase = ''
    runHook preInstall
    install -Dm755 {,$out/bin/}flat-manager-client
    runHook postInstall
  '';

  postFixup = ''
    makeWrapperArgs+=(
      --prefix GI_TYPELIB_PATH : ${lib.makeSearchPath "lib/girepository-1.0" [ ostree ]}
    )

    wrapPythonPrograms $out/bin $out "$pythonPath"
  '';

  meta = flat-manager.meta // {
    mainProgram = "flat-manager-client";
    description = flat-manager.meta.description + " (Client)";
  };
})

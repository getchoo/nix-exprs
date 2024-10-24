{
  lib,
  bash,
  hyfetch,
  installShellFiles,
  makeBinaryWrapper,
  pciutils,
  stdenvNoCC,
  ueberzug,
  withX11Support ? stdenvNoCC.hostPlatform.isLinux,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "neowofetch";

  inherit (hyfetch) version src;

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ];

  buildInputs = [ bash ];

  dontConfigure = true;
  dontBuild = true;

  postInstall = ''
    mv {neo,neowo}fetch
    installBin neowofetch

    mv docs/{neo,neowo}fetch.1
    installManPage docs/neowofetch.1
  '';

  postFixup = ''
    wrapProgram "$out"/bin/neowofetch \
      --prefix PATH : ${lib.makeBinPath finalAttrs.passthru.binPath}
  '';

  passthru = {
    binPath = [ pciutils ] ++ lib.optional withX11Support ueberzug;
  };

  meta = {
    description = "Fast, highly customizable system info script (Maintained fork)";
    homepage = "https://github.com/hykilpikonna/hyfetch";
    changelog = "https://github.com/hykilpikonna/hyfetch/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ getchoo ];
    mainProgram = "neowofetch";
  };
})

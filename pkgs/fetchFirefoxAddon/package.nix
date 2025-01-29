{
  lib,
  stdenvNoCC,
  fetchurl,
}:

lib.makeOverridable (
  lib.fetchers.withNormalizedHash { } (
    {
      url,
      addonId ? null,
      addonSlug ? args.pname or null,
      firefoxVendor ? "mozilla",
      # Keep in sync with https://github.com/nix-community/home-manager/blob/e1ae908bcc30af792b0bb0a52e53b03d2577255e/modules/programs/firefox/mkFirefoxModule.nix#L52-L54
      extensionPath ? "extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}",
      outputHash,
      outputHashAlgo,
      ...
    }@args:

    assert lib.assertMsg (
      addonId != null || addonSlug != null
    ) "One of `addonId` or `addonSlug` must be passed";

    let
      addonRef = if addonId != null then addonId else addonSlug;

      knownArgs = [
        "url"
        "addonId"
        "firefoxVendor"
        "extensionPath"
        "outputHash"
        "outputHashAlgo"
      ];
    in

    stdenvNoCC.mkDerivation (
      finalAttrs:
      lib.removeAttrs args knownArgs
      // {
        name =
          "firefox-addons"
          + lib.optionalString (
            finalAttrs ? "pname" && finalAttrs ? "version"
          ) "-${finalAttrs.pname}-${finalAttrs.version}";

        src = fetchurl {
          inherit url outputHash outputHashAlgo;
        };

        dontConfigure = args.dontConfigure or true;
        dontBuild = args.dontBuild or true;

        installPhase =
          args.installPhase or ''
            runHook preInstall

            extensionDir=$out/share/${firefoxVendor}/${extensionPath}
            install -d $extensionDir
            install -Dm644 $src $extensionDir

            runHook postInstall
          '';

        preferLocalBuild = args.preferLocalBuild or true;
        impureEnvVars = lib.fetchers.proxyImpureEnvVars;

        passthru = args.passthru or { } // {
          inherit
            addonId
            addonRef
            addonSlug
            extensionPath
            firefoxVendor
            ;
        };

        meta = args.meta or { } // {
          position = builtins.unsafeGetAttrPos "url" args;
        };
      }
    )
  )
)

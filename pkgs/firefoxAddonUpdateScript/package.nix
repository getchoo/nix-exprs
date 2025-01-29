{
  lib,
  common-updater-scripts,
  curl,
  jq,
  writeShellApplication,
}:

let
  script = writeShellApplication {
    name = "firefox-addon-update-script";

    runtimeInputs = [
      common-updater-scripts
      curl
      jq
    ];

    text = lib.fileContents ./script.sh;
  };
in

{
  addonRef,
  attrPath,
}:

[
  (lib.getExe script)
  attrPath
  addonRef
]

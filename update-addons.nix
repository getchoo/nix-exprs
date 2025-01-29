{
  pkgs ? import <nixpkgs> {
    inherit system;
    config = { };
    overlays = [ ];
  },
  system ? builtins.currentSystem,
}:

let
  inherit (pkgs) lib;

  getchpkgs = import ./default.nix { inherit pkgs; };
in

pkgs.writeShellApplication {
  name = "update-firefox-addons";

  text = lib.concatLines (
    lib.mapAttrsToList (
      pname: drv:
      lib.escapeShellArgs (
        getchpkgs.firefoxAddonUpdateScript {
          attrPath = "firefox-addons.${pname}";
          inherit (drv.passthru) addonRef;
        }
      )
    ) getchpkgs.firefox-addons
  );
}

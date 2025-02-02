self:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  namespace = "myProgram";
  cfg = config.services.${namespace};

  inherit (pkgs.stdenv.hostPlatform) system;
  packages = self.packages.${system} or throw "myProgram: ${system} is not supported";
in

{
  options.services.${namespace} = {
    enable = lib.mkEnableOption "something amazing";

    package = lib.mkPackageOption packages "hello" { };
  };

  config = {
    environment.systemPackages = [ cfg.package ];
  };
}

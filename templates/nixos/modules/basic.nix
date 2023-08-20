{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (builtins) attrNames map;
  inherit (lib) mkDefault mkEnableOption mkIf mkOption types;
  cfg = config.getchoo.basicConfig;

  mapInputs = fn: map fn (attrNames inputs);
in {
  options.getchoo.basicConfig = {
    enable = mkEnableOption "getchoo's basic config" // {default = true;};
    channelPath = {
      enable =
        mkEnableOption "enable channels"
        // {default = true;};
      dirname = mkOption {
        type = types.str;
        default = "/etc/nix/channels";
        description = "directory where channels are saved";
      };
    };
  };

  config = mkIf cfg.enable {
    nix = {
      gc = {
        automatic = mkDefault true;
        options = mkDefault "-d --delete-older-then 2d";
      };

      settings = {
        auto-optimise-store = true;
        experimental-features = ["nix-command" "flakes" "auto-allocate-uids" "repl-flake"];
      };

      nixPath = mapInputs (i: "${i}=${cfg.channelPath.dirname i}");
    };

    systemd.tmpfiles.rules = mapInputs (i: "L+ ${cfg.channelPath i}     - - - - ${inputs.${i}.outPath}");
  };
}

{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (builtins) attrNames map;
  inherit (lib) filterAttrs mapAttrs mkDefault mkEnableOption mkIf mkOption optionals types;
  cfg = config.getchoo.basicConfig;

  mapInputs = fn: map fn (attrNames inputs);
in {
  options.getchoo.basicConfig = {
    enable = mkEnableOption "getchoo's basic config" // {default = true;};
    channelPath = {
      enable =
        mkEnableOption "enable channel path management"
        // {default = true;};
      dirname = mkOption {
        type = types.str;
        default = "/etc/nix/channels";
        description = "directory where channels are saved";
      };
    };
  };

  config = mkIf cfg.enable {
    nix =
      {
        gc = {
          automatic = mkDefault true;
          options = mkDefault "-d --delete-older-than 2d";
        };

        registry =
          {n.flake = inputs.nixpkgs;}
          // (mapAttrs (_: flake: {inherit flake;})
            (filterAttrs (n: _: n != "nixpkgs") inputs));

        settings = {
          auto-optimise-store = true;
          experimental-features = ["nix-command" "flakes" "auto-allocate-uids" "repl-flake"];
        };
      }
      // mkIf cfg.channelPath.enable {
        nixPath = mapInputs (i: "${i}=${cfg.channelPath.dirname}/${i}");
      };

    systemd.tmpfiles.rules = optionals cfg.channelPath.enable (mapInputs (i: "L+ ${cfg.channelPath.dirname}/${i}     - - - - ${inputs.${i}.outPath}"));
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.firefox;

  policyFormat = pkgs.formats.json { };

  installURLFromId = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

  extensionSettingsSubmodule = lib.types.submodule (
    { config, ... }:
    {
      options = {
        id = lib.mkOption {
          type = lib.types.str;
          description = "Addon ID from addons.mozilla.org";
          example = "uBlock0@raymondhill.net";
        };

        settings = lib.mkOption {
          type = lib.types.submodule {
            freeformType = policyFormat.type;

            options = {
              installation_mode = lib.mkOption {
                type = lib.types.enum [
                  "allowed"
                  "blocked"
                  "force_installed"
                  "normal_installed"
                ];
                default = "normal_installed";
                description = ''
                  Installation mode for the addon.
                  See <link xlink:href="https://mozilla.github.io/policy-templates/#extensionsettings"/>.
                '';
              };

              install_url = lib.mkOption {
                type = lib.types.str;
                default = installURLFromId config.id;
                defaultText = lib.literalExpression ''
                  "https://addons.mozilla.org/firefox/downloads/latest/''${id}/latest.xpi"
                '';
                example = "https://addons.mozilla.org/firefox/downloads/file/4412673/ublock_origin-1.62.0.xpi";
              };
            };
          };
          default = { };
          description = ''
            Configuration for the `ExtensionSettings` policy
            described at
            <link xlink:href="https://mozilla.github.io/policy-templates/#extensionsettings"/>.
          '';
        };
      };
    }
  );

  # Ensure all addons given are submodules describing the `ExtensionSettings` object
  normalizeAddon =
    extensionIdOrSubmodule:
    if lib.isString extensionIdOrSubmodule then
      {
        id = extensionIdOrSubmodule;
        settings = {
          installation_mode = "normal_installed";
          install_url = installURLFromId extensionIdOrSubmodule;
        };
      }
    else
      extensionIdOrSubmodule;
in

{
  options.programs.firefox = {
    addons = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str extensionSettingsSubmodule);
      default = { };
      description = ''
        List of addon IDs from addons.mozilla.org or configuration
        for the `ExtensionSettings` policy described at
        <link xlink:href="https://mozilla.github.io/policy-templates/#extensionsettings"/>.
      '';
      example = lib.literalExpression ''
        [
          # uBlock Origin
          {
            id = "uBlock0@raymondhill.net";
            settings = {
              installation_mode = "force_installed";
            };
          }

          # Bitwarden
          "{446900e4-71c2-419f-a6a7-df9c091e268b}"
        ]
      '';
    };
  };

  config = {
    programs.firefox.policies = {
      ExtensionSettings = lib.foldl' (lib.flip (
        addon:

        let
          normalizedAddon = normalizeAddon addon;
        in

        lib.recursiveUpdate { ${normalizedAddon.id} = normalizedAddon.settings; }
      )) { } cfg.addons;
    };
  };
}

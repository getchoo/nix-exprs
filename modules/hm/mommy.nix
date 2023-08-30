self: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.mommy;
  inherit
    (builtins)
    attrVals
    typeOf
    ;

  inherit
    (lib)
    concatStringsSep
    filterAttrs
    literalExpression
    mapAttrs
    mkDoc
    mkEnableOption
    mkForce
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  mkNull = v: v // {default = null;};

  listOpt = {
    description,
    example,
  }:
    mkOption {
      type = types.listOf types.str;
      default = null;
      example = literalExpression example;
      description = mkDoc description;
    };

  variables = {
    "MOMMY_COMPLIMENTS_ENABLED" = cfg.compliments;
    "MOMMY_ENCOURAGEMENTS_ENABLED" = cfg.encouragements;
    "MOMMY_COMPLIMENTS" = cfg.defaultCompilments;
    "MOMMY_ENCOURAGEMENTS" = cfg.defaultEncouragements;
    "MOMMY_COMPLIMENTS_EXTRA" = cfg.compliments;
    "MOMMY_ENCOURAGEMENTS_EXTRA" = cfg.encouragements;
    "MOMMY_CAREGIVER" = cfg.caregiver;
    "MOMMY_PRONOUNS" = cfg.pronouns;
    "MOMMY_SWEETIE" = cfg.sweetie;
    "MOMMY_PREFIX" = cfg.prefix;
    "MOMMY_SUFFIX" = cfg.suffix;
    "MOMMY_CAPITALIZE" = cfg.capitalize;
    "MOMMY_COLOR" = cfg.color;
    "MOMMY_FORBIDDEN_WORDS" = cfg.forbiddenWords;
    "MOMMY_IGNORED_STATUSES" = cfg.ignoredStatuses;
  };

  filterVars = filterAttrs (_: v: v != null);
  fixupVar = n: v: let
    value =
      if (typeOf v == "list")
      then "${concatStringsSep "/" v}"
      else if (typeOf v == "bool")
      then "${toString v}"
      else v;
  in "${n}=\"${value}\"";

  toConfigFile = variables: let
    fixed = mapAttrs fixupVar (filterVars variables);
  in
    concatStringsSep "\n" (attrVals fixed);
in {
  options.programs.mommy = {
    enable = mkEnableOption "mommy";
    package = mkPackageOption self.packages.${pkgs.hostPlatform.system} "mommy" {};

    capitalize = mkNull (mkEnableOption "sentences in lowercase");
    compliments = mkNull (mkEnableOption "mommy's complements");
    encouragements = mkNull (mkEnableOption "mommy's encouragement");
    defaultCompilments = mkNull (mkEnableOption "mommy's default compilment templates");
    defaultEncouragements = mkNull (mkEnableOption "mommy's default encouragement templates");

    caregiver = listOpt {
      example = ''
        [mommy, mom]
      '';
      description = ''
        what mommy can call herself
      '';
    };

    pronouns = listOpt {
      example = ''
        [they, them, their]
      '';
      description = ''
        mommy's pronouns for herself. should be in the form of subject, object, possessive
      '';
    };

    sweetie = listOpt {
      example = ''
        [boy]
      '';
      description = ''
        what mommy calls you
      '';
    };

    prefix = listOpt {
      example = ''
        ooo
      '';
      description = ''
        what mommy puts at the start of each sentence
      '';
    };

    suffix = listOpt {
      example = ''
        nya!
      '';
      description = ''
        what mommy puts at the end of each sentence
      '';
    };

    color = listOpt {
      example = ''
        ["212"]
      '';
      description = ''
        color of mommy's text. you can use any xterm color code, or write lolcat to use lolcat (install separately).
        specify multiple colors separated by / to randomly select one. set to empty string for your terminal's default color
      '';
    };

    extraCompliments = listOpt {
      example = ''
        ["%%CAREGIVER%% loves you"]
      '';
      description = ''
        additional compliment templates
      '';
    };

    extraEncouragements = listOpt {
      example = ''
        ["you can do it!"]
      '';
      description = ''
        additional encouragement templates
      '';
    };

    forbiddenWords = listOpt {
      example = ''
        ["tomato"]
      '';
      description = ''
        mommy will not use templates that contain forbidden / trigger words
      '';
    };

    ignoredStatuses = listOpt {
      example = ''
        ["130"]
      '';
      description = ''
        exit codes that mommy should never reply to. set to empty string to ignore nothing
      '';
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [cfg.package];

      xdg = {
        enable = mkForce true;
        configFile."mommy/config.sh".text = toConfigFile variables;
      };
    };
  };
}

{
  inputs,
  self,
  ...
}: {
  imports = [
    inputs.effects.flakeModule
  ];

  hercules-ci.flake-update = {
    enable = true;
    autoMergeMethod = "rebase";

    flakes = {
      ".".commitSummary = "flake: update inputs";
    };

    when = {
      minute = 0;
      hour = [0];
      dayOfWeek = ["Sun"];
    };
  };

  herculesCI = {
    config,
    lib,
    ...
  }: let
    findCompatible = lib.filterAttrs (s: _: builtins.elem s config.ciSystems);
  in {
    ciSystems = ["x86_64-linux" "aarch64-linux"];

    onPush.default.outputs = lib.mkForce {
      packages = findCompatible self.packages;
    };
  };
}

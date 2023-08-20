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

  herculesCI = {lib, ...}: let
    ciSystems = ["x86_64-linux" "aarch64-linux"];
    findCompatible = lib.filterAttrs (s: _: builtins.elem s ciSystems);
  in {
    inherit ciSystems;

    onPush.default.outputs = lib.mkForce {
      packages = findCompatible self.packages;
    };
  };
}

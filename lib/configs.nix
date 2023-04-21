# this is mainly for my host/hm configurations
{
  lib,
  inputs,
}: let
  inherit (builtins) mapAttrs readDir;
  inherit (lib) filterAttrs hasPrefix;
in rec {
  mapFilterDir = dir: filter: map: let
    dirs = filterAttrs filter (readDir dir);
  in
    mapAttrs map dirs;

  mapModules = dir: let
    check = n: v: v == "directory" && !(hasPrefix "_" n);
  in
    mapFilterDir dir check;

  mkHMUser = {
    username,
    pkgs,
    modules ? [],
    extraSpecialArgs ? {},
    inputs,
    dir,
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = inputs // extraSpecialArgs;
      modules =
        [
          "${dir}/${username}/home.nix"

          {
            programs.home-manager.enable = true;
          }
        ]
        ++ modules;
    };

  mapHMUsers = system: dir: let
    users = import dir system inputs;
  in
    mapModules dir (
      username: _:
        mkHMUser ({
            inherit username inputs dir;
            inherit (users.${username}) extraSpecialArgs modules pkgs;
          }
          // users.${username})
    );

  mkHost = {
    name,
    modules ? [],
    specialArgs ? {},
    system ? "x86_64-linux",
    inputs ? {},
    builder,
    dir,
  }:
    builder {
      inherit system;
      specialArgs = inputs // specialArgs;
      modules =
        [
          "${dir}/${name}"
        ]
        ++ modules;
    };

  mapHosts = dir: let
    hosts = import "${dir}" inputs;
  in
    mapModules dir (name: _:
      mkHost ({
          inherit name dir inputs;
          inherit (hosts.${name}) builder system;
        }
        // hosts.${name}));
}

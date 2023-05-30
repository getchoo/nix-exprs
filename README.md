# nix-exprs

[![hercules-ci build status](https://img.shields.io/badge/dynamic/json?label=hercules-ci%20builds&query=%24.state&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fgetchoo%2Fnix-exprs%2Fcommits%2Fmain%2Fstatus&color=8f97cb&style=flat-square&logo=github)](https://hercules-ci.com/github/getchoo/nix-exprs)

## how to use

### enable cachix

i have a binary cache at <https://getchoo.cachix.org>, make sure to enable it
in your flake or nixos/darwin config or use `nix run nixpkgs#cachix use getchoo`
for cli support.

### library

> **Note**
> coming soon

### flake configuration

```nix
{
  inputs = {
    getchoo = {
      url = "github:getchoo/nix-exprs";
    };
  };

  outputs = {
    nixpkgs,
    getchoo,
    ...
  }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.overlays = [getchoo.overlays.default];
          environment.systemPackages = with pkgs; [
            treefetch
          ];
        }
      ];
    };
  };
}
```

### nix channels

#### adding the channel

```bash
nix-channel --add https://github.com/getchoo/nix-exprs/archive/main.tar.gz getchoo
nix-channel --update
```

#### usage

```nix
{pkgs, ...}: let
    getchoo = import <getchoo>;
in {
    nixpkgs.overlays = [getchoo.overlays.default];
    environment.systemPackages = with pkgs; [
        treefetch
    ];
}
```

### cli support

this overlay can also be used in the base nix package manager :)

> **Note**
> for nixos/nix-darwin users, `nixpkgs.overlays` does not configure
> overlays for tools such as `nix(-)run`, `nix(-)shell`, etc. so this
> will also be required for you

the best way to make this overlay available for you is to
add it to your flake registry or `~/.config/nixpkgs/overlays.nix`.

#### flake registry

this is the preferred way to use this overlay in the cli, as it allows
for full reproducibility with the flake.

to use this overlay with commands like `nix build/run/shell`, you can
add it to your flake registry:

```shell
nix registry add getchoo github:getchoo/nix-exprs
nix run getchoo#treefetch
```

#### overlays.nix

for those who don't want to use this flake's revision of nixpkgs,
or do not use flakes, you can also add it as an overlay.

[add the channel](#adding-the-channel) to your nix profile, then place
this in `~/.config/nixpkgs/overlays.nix` (or a nix file in `~/.config/nixpkgs/overlays/`):

```nix
let
  getchoo = import <getchoo>;
in [getchoo.overlays.default]
```

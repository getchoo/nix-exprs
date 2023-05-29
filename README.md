# nix-exprs

[![hercules-ci build status](https://img.shields.io/badge/dynamic/json?label=hercules-ci%20builds&query=%24.state&url=https%3A%2F%2Fapi.github.com%2Frepos%2Fgetchoo%2Fnix-exprs%2Fcommits%2Fmain%2Fstatus&color=8f97cb&style=flat-square&logo=github)](https://hercules-ci.com/github/getchoo/nix-exprs)

## how to use

### enable cachix

i have a binary cache at <https://getchoo.cachix.org>, make sure to enable it
in your flake or nixos/darwin config.

### library

> **Note**
> coming soon

### flake configuration

```nix
{
  inputs = {
    getchoo = {
      url = "github:getchoo/overlay";
      inputs.nixpkgs.follows = "nixpkgs";
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

`nixpkgs.overlays` does not configure overlays for tools
such as `nix(-)run`, `nix(-)shell`, etc.

the best way to make this overlay available to them is to
add it to your flake registry or `~/.config/nixpkgs/overlays.nix`.

#### flake registry

```shell
nix registry add getchoo github:getchoo/overlay
nix run getchoo#treefetch
```

#### overlays.nix

[add the channel](#adding-the-channel) to your nix profile, then place
this in `~/.config/nixpkgs/overlays.nix` (or a nix file in `~/.config/nixpkgs/overlays/`):

```nix
let
  getchoo = import <getchoo>;
in [getchoo.overlays.default]
```

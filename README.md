# nix-exprs

[![hydra build status](https://img.shields.io/endpoint?url=https://hydra.mydadleft.me/job/nix-exprs/main/packages.x86_64-linux.treefetch/shield&color=8f97cb&style=flat-square&logo=github)](https://hydra.mydadleft.me/jobset/nix-exprs/main#tabs-jobs)

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

# nix-exprs

[![built with garnix](https://img.shields.io/badge/Built_with-Garnix-blue?style=flat-square&logo=nixos&link=https%3A%2F%2Fgarnix.io)](https://garnix.io)

## how to use

### enable binary cache

all packages are built with [garnix](https://garnix.io/), and cached on their servers. you can use this
yourself by following the instructions [here](https://garnix.io/docs/caching). i would also recommend
[donating](https://opencollective.com/garnix_io) if you can!

example:

```nix
{
  nix.settings = {
    trusted-substituters = [
      "https://cache.garnix.io"
    ];

    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  }
}
```

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

# nix-exprs

[![built with garnix](https://img.shields.io/badge/Built_with-Garnix-blue?style=flat-square&logo=nixos&link=https%3A%2F%2Fgarnix.io)](https://garnix.io)
[![hercules-ci build status](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.github.com%2Frepos%2Fgetchoo%2Fnix-exprs%2Fcommits%2Fmain%2Fstatus&query=state&style=flat-square&logo=github&label=hercules-ci%20build%20status&color=8F97CB)](https://hercules-ci.com/)

## how to use

### enable binary cache

linux packages are built with [hercules-ci](https://hercules-ci.com/), while packages for apple silicon 
are built with [garnix](https://garnix.io/). both have binary caches, however different ones; you can use
garnix's by following the instructions [here](https://garnix.io/docs/caching), and the cachix cache for
hercules-ci by following the instructions [here](https://app.cachix.org/cache/getchoo#pull). i would also recommend
[donating](https://opencollective.com/garnix_io) to garnix if you can!

example:

<details>
<summary>nixos configuration</summary>

```nix
{
  nix.settings = {
    trusted-substituters = [
      "https://cache.garnix.io"
      "https://getchoo.cachix.org"
    ];

    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "getchoo.cachix.org-1:ftdbAUJVNaFonM0obRGgR5+nUmdLMM+AOvDOSx0z5tE="
    ];
  }
}
```

</details>

<details>
<summary>using `cachix` on linux</summary>

```bash
nix run nixpkgs#cachix -- use getchoo
```

</details>

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

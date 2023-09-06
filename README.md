# nix-exprs

[![built with garnix](https://img.shields.io/badge/Built_with-Garnix-blue?style=flat-square&logo=nixos&link=https%3A%2F%2Fgarnix.io)](https://garnix.io)

## how to use

### enabling the binary cache

all packages are built with [garnix](https://garnix.io/), and cached on their servers. you can use this
yourself by following the instructions [here](https://garnix.io/docs/caching). i would also recommend
[donating](https://opencollective.com/garnix_io) if you can!

<details>
<summary>example</summary>

```nix
{
  nix.settings = {
    trusted-substituters = ["https://cache.garnix.io"];

    trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="];
  };
}
```

</details>

### installing packages (flake)

you can add this repository as an input, and optionally override the nixpkgs input to build against
your own revision. from there, you can use packages as an overlay or install them directly

<details>
<summary>with the overlay</summary>

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    getchoo = {
      url = "github:getchoo/nix-exprs";
      # this will break reproducibility, but lower the instances of nixpkgs
      # in flake.lock
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    getchoo,
    ...
  }: let
    getchooModule = {
      nixpkgs.overlays = [getchoo.overlays.default];
      environment.systemPackages = [pkgs.treefetch];
    };
  in {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      modules = [getchooModule];
    };

    darwinConfigurations.hostname = darwin.lib.darwinSystem {
      modules = [getchooModule];
    };
  };
}
```

</details>

<details>
<summary>directly</summary>

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    getchoo = {
      url = "github:getchoo/nix-exprs";
      # this will break reproducibility, but lower the instances of nixpkgs
      # in flake.lock
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    getchoo,
    ...
  }: let
    getchooModule = ({pkgs, ...}: let
      inherit (pkgs.stdenv.hostPlatform) system;
    in {
      environment.systemPackages = [getchoo.packages.${system}.treefetch];
    });
  in {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      modules = [getchooModule];
    };

    darwinConfigurations.hostname = darwin.lib.darwinSystem {
      modules = [getchooModule];
    };
  };
}
```

</details>

### installing packages (without flakes)

this repository uses [flake-compat](https://github.com/edolstra/flake-compat) to allow for non-flake users to
import a channel or the `default.nix` to access the flake's outputs.

<details>
<summary>with the overlay</summary>

```nix
{pkgs, ...}: let
  # install with `nix-channel --add https://github.com/getchoo/nix-exprs/archive/main.tar.gz getchoo`
  getchoo = import <getchoo>;

  # or use `fetchTarball`
  # getchoo = import (builtins.fetchTarball "https://github.com/getchoo/nix-exprs/archive/main.tar.gz");
in {
  nixpkgs.overlays = [getchoo.overlays.default];
  environment.systemPackages = [pkgs.treefetch];
}
```

</details>

<details>
<summary>directly</summary>

```nix
{pkgs, ...}: let
  inherit (pkgs.stdenv.hostPlatform) system;

  # install with `nix-channel --add https://github.com/getchoo/nix-exprs/archive/main.tar.gz getchoo`
  getchoo = import <getchoo>;

  # or use `fetchTarball`
  # getchoo = import (builtins.fetchTarball "https://github.com/getchoo/nix-exprs/archive/main.tar.gz");
in {
  environment.systemPackages = [getchoo.packages.${system}.treefetch];
}
```

</details>

### ad-hoc installation

this flake can also be used in the base nix package manager :)

> **Note**
> for nixos/nix-darwin users, `nixpkgs.overlays` does not configure
> overlays for tools such as `nix(-)run`, `nix(-)shell`, etc. so this
> will also be required for you

the best way to make this overlay available for you is to
add it to your flake registry or `~/.config/nixpkgs/overlays.nix`.

<details>
<summary>flake registry</summary>

this is the preferred way to use this overlay in the cli, as it allows
for full reproducibility with the flake.

to use this overlay with commands like `nix build/run/shell/profile`, you can
add it to your flake registry:

```shell
nix registry add getchoo github:getchoo/nix-exprs
nix profile install getchoo#treefetch
```

</details>

<details>
<summary>overlays.nix</summary>

for those who don't want to use this flake's revision of nixpkgs,
or do not use flakes, you can also add it as an overlay.

first, add the channel for this repository with

```sh
nix-channel --add https://github.com/getchoo/nix-exprs/archive/main.tar.gz getchoo
```

then in `~/.config/nixpkgs/overlays.nix`:

```nix
let
  getchoo = import <getchoo>;
in [getchoo.overlays.default]
```

</details>

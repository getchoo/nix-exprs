# nix-exprs

[![Build status](https://img.shields.io/github/actions/workflow/status/getchoo/nix-exprs/ci.yaml?style=flat-square&logo=github&label=Build%20status&color=5277c3)](https://github.com/getchoo/nix-exprs/actions/workflows/ci.yaml)
[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/getchoo/nix-exprs/badge)](https://flakehub.com/flake/getchoo/nix-exprs)

## how to use

### enabling the binary cache

all packages are cached by [cachix](https://cachix.org). to enable it, you can run
`nix run nixpkgs#cachix use getchoo`. it may may also be used in the `nixConfig` attribute
of flakes or in a system configuration.

<details>
<summary>example</summary>

```nix
{pkgs, ...}: {
  nix.settings = {
    trusted-substituters = ["https://getchoo.cachix.org"];
    trusted-public-keys = ["getchoo.cachix.org-1:ftdbAUJVNaFonM0obRGgR5+nUmdLMM+AOvDOSx0z5tE="];
  };
}
```

</details>

### flake-based

flakes are the primary method to use this repository

#### installing packages

you can add this repository as an input, and optionally override the nixpkgs input to build against
your own revision of nixpkgs

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
      # in flake.lock and possibly duplicated dependencies
      # inputs.nixpkgs.follows = "nixpkgs";
      # if you want to save some space
      # inputs.flake-checks.follows = "";
    };
  };

  outputs = {
    nixpkgs,
    getchoo,
    ...
  }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix

        ({pkgs, ...}: {
          environment.systemPackages = with getchoo.packages.${pkgs.system}; [
            treefetch
          ];
        })
      ];
    };
  };
}
```

#### ad-hoc installation

this flake can also be used in the base nix package manager!

the best way to make these packages available for you is to
add it to your flake registry like so.

```sh
nix registry add getchoo github:getchoo/nix-exprs
nix profile install getchoo#treefetch
nix shell getchoo#cfspeedtest
```

### stable nix

there are two main ways to use this repository with stable nix: channels and [`npins`](https://github.com/andir/npins) (or similar)

to add the channel, run:

```sh
nix-channel --add https://github.com/getchoo/nix-exprs/archive/main.tar.gz getchoo
nix-channel --update getchoo

```

to use `npins`, please view the [getting started guide](https://github.com/andir/npins?tab=readme-ov-file#getting-started) to initialize your project.
after, run:

```sh
npins add --name getchoo github getchoo nix-exprs
```

#### installing packages

```nix
{ pkgs, ... }: let
  # if you use channels
  getchoo = import <getchoo>;

  # or if you use `npins`
  # sources = import ./npins;
  # getchoo = import sources.getchoo;
in {
  environment.systemPackages = [ getchoo.treefetch ];
}
```

#### ad-hoc installation

channels are the recommended method of adhoc-installation and usage. after adding it with the command above, you can use it like so:

```sh
nix-env -f '<getchoo>' -iA treefetch
nix-shell '<getchoo>' -p treefetch
```

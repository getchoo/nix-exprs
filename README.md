# nix-exprs

[![Build status](https://img.shields.io/github/actions/workflow/status/getchoo/nix-exprs/ci.yaml?style=flat-square&logo=github&label=Build%20status&color=5277c3)](https://github.com/getchoo/nix-exprs/actions/workflows/ci.yaml)
[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/getchoo/nix-exprs/badge)](https://flakehub.com/flake/getchoo/nix-exprs)

My nix expressions not quite ready for nixpkgs yet - if ever

## How to Use

### Enabling the Binary Cache

All packages are cached by [cachix](https://cachix.org). To enable it, you can run
`nix run nixpkgs#cachix use getchoo`. It may may also be used in the `nixConfig` attribute
of Flakes or in a system configuration.

<details>
<summary>Example</summary>

```nix
{ pkgs, ... }: {
  nix.settings = {
    trusted-substituters = [ "https://getchoo.cachix.org" ];
    trusted-public-keys = [ "getchoo.cachix.org-1:ftdbAUJVNaFonM0obRGgR5+nUmdLMM+AOvDOSx0z5tE=" ];
  };
}
```

</details>

### Flake-based

Flakes are the primary method to use this repository

#### Installing Packages

You can add this repository as an input, and optionally override the nixpkgs input to build against
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

  outputs =
    { nixpkgs, getchoo, ... }:
    {
      nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
          (
            { pkgs, ... }:
            let
              inherit (pkgs.stdenv.hostPlatform) system;
            in
            {
              environment.systemPackages = [
                getchoo.packages.${system}.treefetch
              ];
            }
          )
        ];
      };
    };
}
```

#### Ad-hoc Installation

This Flake can also be used in the base Nix package manager!

The best way to make these packages available for you is to
add it to your flake registry like so:

```console
$ nix registry add getchoo 'github:getchoo/nix-exprs'
$ nix profile install 'getchoo#treefetch'
$ nix shell 'getchoo#treefetch'
```

### Stable Nix

There are two main ways to use this repository with stable Nix: channels and [`npins`](https://github.com/andir/npins) (or similar)

To add the channel, run:

```console
$ nix-channel --add https://github.com/getchoo/nix-exprs/archive/main.tar.gz getchoo
$ nix-channel --update getchoo
```

To use `npins`, please view their [Getting Started guide](https://github.com/andir/npins?tab=readme-ov-file#getting-started) to initialize your project.
After, run:

```console
$ npins add --name getchoo github getchoo nix-exprs
```

#### Installing Packages

```nix
{ pkgs, ... }: let
  # If you use channels
  getchoo = import <getchoo> {
    # Add this if you want to use your own nixpkgs
    inherit pkgs;
  };

  # Or if you use `npins`
  # sources = import ./npins;
  # getchoo = import sources.getchoo { };
in {
  environment.systemPackages = [ getchoo.treefetch ];
}
```

#### Ad-hoc Installation

Channels are the recommended method of adhoc-installation and usage. After adding it with the command above, you can use it like so:

```console
$ nix-env -f '<getchoo>' -iA treefetch
$ nix-shell '<getchoo>' -p treefetch
```

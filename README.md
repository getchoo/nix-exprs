# nix-exprs

[![Build status](https://img.shields.io/github/actions/workflow/status/getchoo/nix-exprs/ci.yaml?style=flat-square&logo=github&label=Build%20status&color=5277c3)](https://github.com/getchoo/nix-exprs/actions/workflows/ci.yaml)

## how to use

### enabling the binary cache

all packages are cached in my own [attic](https://github.com/zhaofengli/attic) instance. you can use this
yourself by following the instructions [here](https://docs.attic.rs/user-guide/index.html), with the endpoint
being `https://cache.mydadleft.me` and no token required. the binary cache endpoint `https://cache.mydadleft.me/nix-exprs`
may also be used in the `nixConfig` attribute of flakes or a system configuration.

<details>
<summary>example</summary>

```nix
{pkgs, ...}: {
  nix.settings = {
    trusted-substituters = ["https://cache.mydadleft.me/nix-exprs"];
    trusted-public-keys = ["nix-exprs:mLifiLXlGVkkuFpIbqcrCWkIxKn2GyCkrxOuE7fwLxQ="];
  };
}
```

</details>

### flake-based

flakes are the primary supported method to use this repository - and in my opinion, can offer a much
nicer user experience :)

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

<details>
<summary>using the overlay</summary>

the overlay (though not preferred for the sake of reproducibility) is also an
option for those who want to avoid the verbosity of installing packages directly,
a "plug-n-play" solution to using the packages, and/or a reduction in duplicated dependencies.

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
      # this should probably be used in this scenario as reproducibility is
      # already broken by using an overlay
      inputs.nixpkgs.follows = "nixpkgs";
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
          nixpkgs.overlays = [getchoo.overlays.default];
          environment.systemPackages = with pkgs; [
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

> **Note**
> for nixos/nix-darwin users, `nixpkgs.overlays` does not configure
> overlays for tools such as `nix(-)run`, `nix(-)shell`, etc. so this
> will also be required for you

the best way to make this overlay available for you is to
add it to your flake registry like so.

```sh
nix registry add getchoo github:getchoo/nix-exprs
nix profile install getchoo#treefetch
nix shell getchoo#cfspeedtest
```

</details>

### standard nix

this repository uses [flake-compat](https://github.com/edolstra/flake-compat) to allow for non-flake environments to use the packages provided.

there are two ways to do this: through channels or `fetchTarball` (or similar functions). i personally recommend
channels as they are the easiest to update - though if you want to pin a specific revision of this repository,
`fetchTarball` would probably be a better alternative.

to add the channel, run:

```sh
nix-channel --add https://github.com/getchoo/nix-exprs/archive/main.tar.gz getchoo
nix-channel --update getchoo

```

to use `fetchTarball`, please view the [documentation](https://nixos.org/manual/nix/stable/language/builtins.html?highlight=fetchtarball#builtins-fetchTarball) as there are a fair number of ways to use it.
at it's most basic, you could use this:

```nix
{
  getchoo = import (builtins.fetchTarball "https://github.com/getchoo/nix-exprs/archive/main.tar.gz");
}
```

#### installing packages

```nix
{pkgs, ...}: let
  # if you use channels
  getchoo = import <getchoo>;

  # or if you use `fetchTarball`
  # getchoo = import (builtins.fetchTarball "https://github.com/getchoo/nix-exprs/archive/main.tar.gz");
in {
  environment.systemPackages = [getchoo.packages.${pkgs.system}.treefetch];
}
```

<details>
<summary>with the overlay</summary>

```nix
{pkgs, ...}: let
  # if you use channels
  getchoo = import <getchoo>;

  # or if you use `fetchTarball`
  # getchoo = import (builtins.fetchTarball "https://github.com/getchoo/nix-exprs/archive/main.tar.gz");
in {
  nixpkgs.overlays = [getchoo.overlays.default];
  environment.systemPackages = [pkgs.treefetch];
}
```

</details>

#### ad-hoc installation

there are two ways to use ad-hoc commands: through channels or `overlays.nix`.

channels are again then the preferred method here, where once it's added it can be used
like so:

```sh
nix-env -f '<getchoo>' -iA getchoo.packages.x86_64-linux.treefetch # replace x86_64-linux with your system
nix-shell '<getchoo>' -p treefetch
```

<details>
<summary>overlays.nix</summary>

for those who don't want to use this flake's revision of nixpkgs - or have the verbosity
of the `flake-compat` provided commands - `overlays.nix` is a good option.

in `~/.config/nixpkgs/overlays.nix`:

```nix
let
  # if you use channels
  getchoo = import <getchoo>;

  # or if you use `fetchTarball`
  # getchoo = import (builtins.fetchTarball "https://github.com/getchoo/nix-exprs/archive/main.tar.gz");
in [getchoo.overlays.default]
```

</details>

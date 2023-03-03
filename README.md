# overlay

my personal nix overlay :)

## current packages

see [PACKAGES.md](https://github.com/getchoo/overlay/blob/main/PACKAGES.md)

## how to use

### on nixos

#### flake configuration:

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

#### configuration.nix

```nix
_: let
  getchoo = builtins.fetchTarball "https://github.com/getchoo/overlay/archive/refs/heads/main.tar.gz";
in {
  nixpkgs.overlays = [getchoo.overlay.default];
}
```

### cli support

`nixpkgs.overlays` does not configure overlays for tools such as `nix(-)run`, `nix(-)shell`, etc.
the best way to make this overlay available for them is to add it to your flake registry or `~/.config/nixpkgs/overlays.nix`.

#### flake registry

```shell
nix registry add getchoo github:getchoo/overlay
nix run getchoo#treefetch
```

### overlays.nix

in `~/.config/nixpkgs/overlays.nix` (or a nix file in `~/.config/nixpkgs/overlays/`):

```nix
let
  getchoo = import (builtins.fetchTarball "https://github.com/getchoo/overlay/archive/refs/heads/main.tar.gz");
in [getchoo.overlays.default]
```

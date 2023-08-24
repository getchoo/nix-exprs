{
  description = "";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    pre-commit = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.flake-compat.follows = "compat";
    };
  };

  outputs = {
    parts,
    pre-commit,
    ...
  } @ inputs:
    parts.lib.mkFlake {inherit inputs;} {
      imports = [
        pre-commit.flakeModule
        ./nix
      ];
    };
}

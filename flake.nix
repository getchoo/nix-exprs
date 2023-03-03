{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    utils,
    naersk,
    ...
  }: let
    supportedSystsems = with utils.lib.system; [
      x86_64-linux
      # x86_64-darwin
      # aarch64-linux
      # aarch64-darwin
    ];
    packageSet = pkgs:
      with pkgs; {
        treefetch = callPackage ./pkgs/treefetch.nix {inherit naersk;};
      };
    overrides = prev: {
      discord-canary = import ./pkgs/discord-canary.nix prev;
    };
  in
    utils.lib.eachSystem supportedSystsems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      formatter = pkgs.alejandra;
      packages = let
        p = packageSet pkgs;
      in
        p // {default = p.treefetch;};
    })
    // {
      overlays.default = final: prev: packageSet final // overrides prev;
    };
}

{
  description = "";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    inherit (nixpkgs) lib;

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = fn: lib.genAttrs systems (sys: fn nixpkgs.legacyPackages.${sys});
  in {
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          bash
        ];
      };
    });

    formatter = forAllSystems (pkgs: pkgs.alejandra);

    packages = forAllSystems (pkgs: let
      pkgs' = lib.fix (final: self.overlays.default final pkgs);
    in {
      inherit (pkgs') hello;
      default = pkgs'.hello;
    });

    overlays.default = _: prev: {
      foo = prev.callPackage ./. {inherit self;};
    };
  };
}

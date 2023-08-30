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
    version = builtins.substring 0 8 self.lastModifiedDate or "dirty";

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    genSystems = lib.genAttrs systems;
    nixpkgsFor = genSystems (sys: nixpkgs.legacyPackages.${sys});
    forAllSystems = fn: genSystems (sys: fn nixpkgsFor.${sys});

    packageFn = pkgs: {
      hello = pkgs.callPackage ./default.nix {inherit self version;};
    };
  in {
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          bash
        ];
      };
    });

    formatter = forAllSystems (p: p.alejandra);

    packages = forAllSystems (pkgs: {
      inherit (pkgs) hello;
      default = pkgs.hello;
    });

    overlays.default = _: prev: (packageFn prev);
  };
}

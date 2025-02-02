{
  description = "";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:

    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = lib.genAttrs systems;
    in

    {
      checks = forAllSystems (
        system:

        let
          pkgs = nixpkgs.legacyPackages.${system};

          mkCheck =
            name: deps: script:
            pkgs.runCommand name { nativeBuildInputs = deps; } ''
              ${script}
              touch $out
            '';
        in

        {
          nixfmt = mkCheck "check-nixfmt" [ pkgs.nixfmt-rfc-style ] "nixfmt --check ${self}/**.nix";
        }
      );

      devShells = forAllSystems (
        system:

        let
          pkgs = nixpkgs.legacyPackages.${system};
        in

        {
          default = import ./shell.nix {
            inherit pkgs;
            inherit (self.packages.${system}) hello;
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      nixosModules.default = lib.modules.importApply ./nix/module.nix { inherit self; };

      packages = forAllSystems (
        system:

        let
          pkgs = nixpkgs.legacyPackages.${system};

          pkgs' = import ./default.nix { inherit pkgs; };
        in

        pkgs' // { default = pkgs'.hello or pkgs.emptyFile; }
      );
    };
}

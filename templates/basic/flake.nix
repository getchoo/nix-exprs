{
  description = "";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

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
      nixpkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          nixfmt = pkgs.runCommand "check-nixfmt" ''
            cd ${self}

            echo "Running nixfmt..."
            ${lib.getExe self.formatter.${system}}--check .

            touch $out
          '';
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.bash ];

            inputsFrom = [ self.packages.${system}.hello ];
          };
        }
      );

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-rfc-style);

      packages = forAllSystems (
        system:
        let
          pkgs = import ./. {
            inherit system nixpkgs lib;
            pkgs = nixpkgsFor.${system};
          };

          isAvailable = lib.meta.availableOn { inherit system; };
          pkgs' = lib.filterAttrs (_: isAvailable) pkgs;
        in
        pkgs // { default = pkgs'.hello; }
      );
    };
}

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
      nixpkgsFor = nixpkgs.legacyPackages;
    in
    {
      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};

          mkCheck =
            name: deps: script:
            pkgs.runCommand name { nativeBuildInputs = deps; } script;
        in
        {
          nixfmt = mkCheck "check-nixfmt" [ pkgs.nixfmt-rfc-style ] ''
            nixfmt --check ${self}

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
          pkgs = import ./default.nix {
            pkgs = nixpkgsFor.${system};
          };

          isAvailable = lib.meta.availableOn { inherit system; };
          pkgs' = lib.filterAttrs (_: isAvailable) pkgs;
        in
        pkgs // { default = pkgs'.hello or pkgs.emptyFile; }
      );
    };
}

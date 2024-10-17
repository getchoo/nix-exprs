{
  description = "My cool Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
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
      nixosConfigurations.myComputer = nixpkgs.lib.nixosSystem {
        modules = [ ./configuration.nix ]; # You should already have this
        specialArgs = {
          # Gives your configuration.nix access to the inputs from above
          inherit inputs;
        };
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            packages = [
              pkgs.fzf
              pkgs.just

              # Lets you run `nixfmt` to format all of your files
              self.formatter.${system}
            ];
          };
        }
      );

      # You can also use `nix fmt`
      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-rfc-style);
    };
}

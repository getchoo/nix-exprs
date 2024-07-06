{
  description = "";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = fn: nixpkgs.lib.genAttrs systems (sys: fn nixpkgs.legacyPackages.${sys});
      version = self.shortRev or self.dirtyShortRev or "unknown";
    in
    {
      devShells = forAllSystems (
        { pkgs, system, ... }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [ bash ];

            inputsFrom = [ self.packages.${system}.hello ];
          };
        }
      );

      formatter = forAllSystems (pkgs: pkgs.alejandra);

      packages = forAllSystems (
        { pkgs, system, ... }:
        {
          hello = pkgs.callPackage ./. { inherit version; };
          default = self.packages.${system}.hello;
        }
      );

      overlays.default = _: prev: { hello = prev.callPackage ./. { inherit version; }; };
    };
}

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
    version = builtins.substring 0 8 self.lastModifiedDate;

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      });

    forEachSystem = fn:
      forAllSystems (system:
        fn {
          inherit system;
          pkgs = nixpkgsFor.${system};
        });
  in {
    devShells = forEachSystem ({pkgs, ...}: let
      inherit (pkgs) mkShell;
    in {
      default = mkShell {
        packages = with pkgs; [
          bash
        ];
      };
    });

    formatter = forEachSystem ({pkgs, ...}: pkgs.alejandra);

    packages = forEachSystem ({pkgs, ...}: {
      inherit (pkgs) hello;
      default = pkgs.hello;
    });

    overlays.default = _: prev: {
      hello = prev.stdenv.mkDerivation {
        pname = "hello";
        inherit version;

        src = self;

        installPhase = ''
          echo "hi" > $out
        '';

        meta = with prev.lib; {
          description = "";
          homepage = "";
          license = licenses.mit;
          maintainers = [maintainers.getchoo];
          platforms = platforms.linux;
        };
      };
    };
  };
}

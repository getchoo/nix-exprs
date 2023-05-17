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

    packageFn = pkgs: let
      inherit (pkgs.lib) licenses maintainers platforms;
    in {
      hello = pkgs.stdenv.mkDerivation rec {
        pname = "hello";
        inherit version;

        src = builtins.path {
          name = "${pname}-src";
          path = ./.;
        };

        installPhase = ''
          echo "hi" > $out
        '';

        meta = {
          description = "";
          homepage = "";
          license = licenses.mit;
          maintainers = [maintainers.getchoo];
          platforms = platforms.linux;
        };
      };
    };
  in {
    devShells = forAllSystems (s: let
      pkgs = nixpkgsFor.${s};
      inherit (pkgs) mkShell;
    in {
      default = mkShell {
        packages = with pkgs; [
          bash
        ];
      };
    });

    formatter = forAllSystems (s: nixpkgsFor.${s}.alejandra);

    packages = forAllSystems (s: rec {
      inherit (nixpkgsFor.${s}) hello;
      default = hello;
    });

    overlays.default = final: _: packageFn final;
  };
}

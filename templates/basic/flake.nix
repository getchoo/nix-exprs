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
    version = builtins.substring 0 8 self.lastModifiedDate or "dirty";

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    genSystems = nixpkgs.lib.genAttrs systems;
    nixpkgsFor = genSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      });

    forAllSystems = fn: genSystems (sys: fn nixpkgsFor.${sys});
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

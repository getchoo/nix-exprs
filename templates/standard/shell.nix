{
  pkgs ? import nixpkgs {
    inherit system;
    config = { };
    overlays = [ ];
  },
  nixpkgs ? <nixpkgs>,
  system ? builtins.currentSystem,
  hello ? (import ./default.nix { inherit pkgs; }).hello,
}:

pkgs.mkShell {
  packages = [ pkgs.bash ];

  inputsFrom = [ hello ];
}

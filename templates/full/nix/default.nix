{
  imports = [
    ./shell.nix
    ./packages.nix
  ];

  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-rfc-style;
    };
}

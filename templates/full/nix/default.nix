{
  imports = [
    ./shell.nix
    ./packages.nix
  ];

  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
  };
}

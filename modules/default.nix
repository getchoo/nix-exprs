{
  flake = {
    flakeModules = {
      default = import ./flake;
      homeConfigurations = import ./flake/homeConfigurations.nix;
      homeManagerModules = import ./flake/homeManagerModules.nix;
      hydraJobs = import ./flake/hydraJobs.nix;
    };
  };
}

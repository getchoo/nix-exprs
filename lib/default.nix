lib: {inputs, ...}: {
  ci = import ./ci.nix lib;
  configs = import ./configs.nix inputs;
}

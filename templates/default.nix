self:
let
  # string -> string -> {}
  toTemplate = name: description: {
    path = self + "/templates/" + name;
    inherit description;
  };
in
builtins.mapAttrs toTemplate {
  basic = "minimal boilerplate for my flakes";
  full = "big template for complex flakes (using flake-parts)";
  nixos = "minimal boilerplate for flake-based nixos configuration";
}

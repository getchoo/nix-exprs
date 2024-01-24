let
  # string -> string -> {}
  toTemplate = name: description: {
    path = builtins.path {
      path = ./${name};
      name = "${name}-template";
    };

    inherit description;
  };
in
  builtins.mapAttrs toTemplate {
    basic = "minimal boilerplate for my flakes";
    full = "big template for complex flakes (using flake-parts)";
    nixos = "minimal boilerplate for flake-based nixos configuration";
  }

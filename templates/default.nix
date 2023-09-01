{
  flake = {
    templates = let
      # string -> string -> {}
      mkTemplate = name: description: {
        path = ./${name};
        inherit description;
      };
    in {
      basic = mkTemplate "basic" "minimal boilerplate for my flakes";
      full = mkTemplate "full" "big template for complex flakes (using flake-parts)";
      nixos = mkTemplate "nixos" "minimal boilerplate for flake-based nixos configuration";
    };
  };
}

lib: inputs: let
  inherit (lib) forEach genAttrs removeSuffix;
  files = let
    inherit (builtins) attrNames readDir;
    inherit (lib) filterAttrs hasSuffix;
    check = n: v: n != "default.nix" && hasSuffix ".nix" n && v == "regular";
    dir = readDir ./.;
  in
    attrNames (filterAttrs check dir);
in
  genAttrs (forEach files (removeSuffix ".nix")) (f: (import ./${f + ".nix"} {inherit lib inputs;}))

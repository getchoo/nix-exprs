{
  lib,
  stdenv,
  version,
  ...
}: let
  inherit (lib) licenses maintainers platforms;
in
  stdenv.mkDerivation rec {
    pname = "hello";
    inherit version;

    src = builtins.path {
      name = "${pname}-src";
      path = ./.;
    };

    installPhase = ''
      echo "hi" > $out
    '';

    meta = {
      description = "";
      homepage = "";
      license = licenses.mit;
      maintainers = [maintainers.getchoo];
      platforms = platforms.linux;
    };
  }

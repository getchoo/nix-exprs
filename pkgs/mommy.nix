{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gnumake,
  man-db,
  shellspec,
  ...
}: let
  inherit (lib) licenses maintainers platforms;
in
  stdenvNoCC.mkDerivation rec {
    pname = "mommy";
    version = "1.2.3";

    src = fetchFromGitHub {
      owner = "FWDekker";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-LT21MJg2rF84o2rWKguEP4UUOOu27nNGls95sBYgICw=";
    };

    checkInputs = [man-db shellspec];
    nativeBuildInputs = [gnumake];

    checkPhase = ''
      make test/unit
    '';

    installPhase = ''
      make prefix=$out install
    '';

    meta = {
      description = "mommy's here to support you, in any shell, on any system~";
      longDescription = ''
        mommy's here to support you! mommy will compliment you if things go well,
        and will encourage you if things are not going so well~
      '';
      homepage = "https://github.com/FWDekker/mommy";
      license = licenses.unlicense;
      maintainers = [maintainers.getchoo];
      platforms = with platforms; linux ++ darwin;
    };
  }

{
  lib,
  stdenv,
  self,
  version,
  ...
}:
stdenv.mkDerivation {
  pname = "hello";
  inherit version;

  src = lib.cleanSource self;

  installPhase = ''
    echo "hi" > $out
  '';

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.mit;
    maintainers = [maintainers.getchoo];
    platforms = platforms.linux;
  };
}

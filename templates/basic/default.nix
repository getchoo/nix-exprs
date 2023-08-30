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

  src = self;

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

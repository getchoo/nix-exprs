{
  lib,
  fetchPypi,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "material-color-utilities";
  version = "0.1.5";
  src = fetchPypi {
    pname = "${pname}-python";
    inherit version;
    sha256 = "sha256-PG8C585wWViFRHve83z3b9NijHyV+iGY2BdMJpyVH64=";
  };

  nativeBuildInputs = with python3Packages; [poetry-core];
  propagatedBuildInputs = with python3Packages; [pillow regex];

  meta = with lib; {
    description = "Python port of material-color-utilities used for Material You colors";
    license = licenses.asl20;
    maintainers = with maintainers; [getchoo];
    platforms = platforms.all;
  };
}

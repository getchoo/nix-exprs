self: {
  lib,
  runCommand,
  system,
  actionlint,
  fd,
  statix,
  nil,
  ...
}: let
  formatter = self.formatter.${system};
in {
  check-actionlint = runCommand "check-actionlint" {} ''
    ${lib.getExe actionlint} ${./.github/workflows}/*

    touch $out
  '';

  check-nil = runCommand "check-nil" {} ''
    cd ${./.}
    ${lib.getExe fd} . -e 'nix' | while read -r file; do
      ${lib.getExe nil} diagnostics "$file"
    done

    touch $out
  '';

  check-statix = runCommand "check-statix" {} ''
    ${lib.getExe statix} check ${./.}
    touch $out
  '';

  "check-${formatter.pname}" = runCommand "check-${formatter.pname}" {} ''
    ${lib.getExe formatter} --check ${./.}
    touch $out
  '';
}

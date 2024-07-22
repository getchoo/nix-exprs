{
  projectRootFile = ".git/config";

  # TODO: add actionlint
  # https://github.com/numtide/treefmt-nix/pull/146
  programs = {
    deadnix.enable = true;
    nixfmt.enable = true;
    statix.enable = true;
  };
}

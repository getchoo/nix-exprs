{
  fetchFromGitHub,
  vimUtils,
}:
vimUtils.buildVimPluginFrom2Nix {
  pname = "vim-just";
  version = "unstable-2023-07-30";

  src = fetchFromGitHub {
    owner = "NoahTheDuke";
    repo = "vim-just";
    rev = "9129b096a6b43e0a47e405cc7b3fb55bc0e31c42";
    sha256 = "sha256-GR+xY2MF5lT+mxeHccjijFAuSfuhSR4Gfwmtals3UBM=";
  };
}

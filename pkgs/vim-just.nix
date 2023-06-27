{
  fetchFromGitHub,
  vimUtils,
}:
vimUtils.buildVimPluginFrom2Nix {
  pname = "vim-just";
  version = "2023-04-21";

  src = fetchFromGitHub {
    owner = "NoahTheDuke";
    repo = "vim-just";
    rev = "9fc9a1afaa9e3567b25f4141a01f6172a1992a0b";
    sha256 = "sha256-O3HCNOVlo3MAkTQw622n5KTUIVPZd4HJvOXyDZbEWXI=";
  };
}

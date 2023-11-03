{
  fetchFromGitHub,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "vim-just";
  version = "unstable-2023-11-01";

  src = fetchFromGitHub {
    owner = "NoahTheDuke";
    repo = "vim-just";
    rev = "3451e22daade268f99b1cfeb0d9fe39f4ddc06d5";
    sha256 = "sha256-2pzdtMGdmCTprkPslGdlEezdQ6dTFrhqvz5Sc8DN3Ts=";
  };
}

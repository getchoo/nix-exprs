{
  fetchFromGitHub,
  vimUtils,
}:
vimUtils.buildVimPluginFrom2Nix {
  pname = "vim-just";
  version = "unstable-2023-07-24";

  src = fetchFromGitHub {
    owner = "NoahTheDuke";
    repo = "vim-just";
    rev = "8e5c882f8d6fb213b160ac2cbb5b28fea620ed0b";
    sha256 = "sha256-cCm/TGOUa2/oyM5YSlw7rdo/2BjyEgsoZWKRvvY4YJ4=";
  };
}

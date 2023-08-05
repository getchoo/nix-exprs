{
  fetchFromGitHub,
  vimUtils,
}:
vimUtils.buildVimPluginFrom2Nix {
  pname = "vim-just";
  version = "unstable-2023-08-02";

  src = fetchFromGitHub {
    owner = "NoahTheDuke";
    repo = "vim-just";
    rev = "927b41825b9cd07a40fc15b4c68635c4b36fa923";
    sha256 = "sha256-BmxYWUVBzTowH68eWNrQKV1fNN9d1hRuCnXqbEagRoY=";
  };
}

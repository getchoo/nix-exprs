{
  fetchFromGitHub,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "vim-just";
  version = "unstable-2023-10-20";

  src = fetchFromGitHub {
    owner = "NoahTheDuke";
    repo = "vim-just";
    rev = "3029bdda0da9674682fe46bd6c4b946ad229dcaa";
    sha256 = "sha256-I6pn80ULBHSblQkGzA/+lup/hHbWdAOdlTq2m3JbDVU=";
  };
}

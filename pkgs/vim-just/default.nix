{
  fetchFromGitHub,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "vim-just";
  version = "unstable-2023-10-13";

  src = fetchFromGitHub {
    owner = "NoahTheDuke";
    repo = "vim-just";
    rev = "3038ffac026a13edaf1bbb898f25d808b6b0c92a";
    sha256 = "sha256-u+prgGpZPSmHrDTnIXcQYG7bAfIOjtjhDHODvR2UA7Y=";
  };
}

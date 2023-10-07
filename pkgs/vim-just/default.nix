{
  fetchFromGitHub,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "vim-just";
  version = "unstable-2023-10-06";

  src = fetchFromGitHub {
    owner = "NoahTheDuke";
    repo = "vim-just";
    rev = "fbcfcf96cf7c67cf0d4ad15b7af5069f65440c4f";
    sha256 = "sha256-gCljLZcSbN738bNMQDFF+N5kVC7+Q3tsB5FlozFbiqs=";
  };
}

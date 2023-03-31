{
  fetchFromGitHub,
  vimUtils,
}: let
  inherit (builtins) substring;
  inherit (vimUtils) buildVimPluginFrom2Nix;
  rev = "18246a7cbb8b82c0682e9a49039bb5c376b79a6c";
in
  buildVimPluginFrom2Nix {
    pname = "vim-just";
    version = substring 0 7 rev;
    src = fetchFromGitHub {
      owner = "NoahTheDuke";
      repo = "vim-just";
      inherit rev;
      sha256 = "sha256-KNmt9Axpl/uRj4wKzWkjcvHKCdjShsBjEVK1kFQ2VzE=";
    };
  }

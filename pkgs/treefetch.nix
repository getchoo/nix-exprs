{
  lib,
  callPackage,
  fetchFromGitHub,
  naersk,
}: let
  commit = "02f65e11e1f23d5fa9e66335eb5ff4f2f6b01400";
  package = (callPackage naersk {}).buildPackage {
    src = fetchFromGitHub {
      owner = "angelofallars";
      repo = "treefetch";
      rev = commit;
      sha256 = "sha256-FDiulTit492KwV46A3qwjHQwzpjVJvIXTfTrMufXd5k=";
    };
  };
in
  with lib;
    package
    // {
      meta =
        package.meta
        // {
          description = "A plant-based system fetch tool made with Rust.";
          longDescription = "A comfy and fast system fetch tool made in Rust. Tested to be much faster than neofetch and pfetch.";
          homepage = "https://github.com/angelofallars/treefetch";
          license = licenses.gpl3;
          maintainers = with maintainers; [getchoo];
          platforms = platforms.all;
        };
    }

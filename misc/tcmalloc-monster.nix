# this uses a cherry-picked version of nixpkgs with llvm 16
# to build a 32-bit, statically linked version of tcmalloc
#
# i'm using it to test ways to solve crashes in tf2 on
# systems with mesa also compiled against llvm 16
let
  commit = "2c627d9c702202d75746fd45045d20008bf7ed86";
  nixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/RaitoBezarius/nixpkgs/archive/${commit}.tar.gz";
    sha256 = "sha256:002sz5nqsr7nvwp6bdapwmb691snhrcwdlp4flbhwgqgfzzpyksc";
  }) {system = "x86_64-linux";};

  inherit (nixpkgs.llvmPackages_16) stdenv;
  inherit (nixpkgs.pkgsi686Linux.pkgsStatic) gperftools;
in
  gperftools.override {inherit stdenv;}

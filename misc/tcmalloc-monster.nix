# this uses llvm 16 to build a 32-bit version of tcmalloc,
# with a 64 and 32-bit version of mesa
#
# i'm using it to test ways to solve crashes in tf2 on
# systems with mesa also compiled against llvm 16
let
  nixpkgs = import (builtins.getFlake "github:nixos/nixpkgs") {system = "x86_64-linux";};

  inherit (nixpkgs) llvmPackages_16 mesa pkgsi686Linux;
  inherit (pkgsi686Linux) gperftools;

  x64Stdenv = llvmPackages_16.stdenv;
  i686Stdenv = pkgsi686Linux.llvmPackages_16.stdenv;
  mesa-i686 = pkgsi686Linux.mesa;
in {
  mesa-llvm16 = mesa.override {stdenv = x64Stdenv;};
  mesa-llvm16-32bit = mesa-i686.override {stdenv = i686Stdenv;};
  gperftools-llvm16-32bit = gperftools.override {stdenv = i686Stdenv;};
}

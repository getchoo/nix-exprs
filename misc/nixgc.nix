# this is a shell script that uses the new nix cli to emulate
# nix-collect-garbage
with (import (builtins.getFlake "nixpkgs") {});
  writeScriptBin "nixgc" ''
    #!${fish}/bin/fish
    set -l profiles (find /nix/var/nix/profiles/ -maxdepth 3 -type l -not -name '*-link')

    for profile in $profiles
    	sudo nix profile wipe-history --profile $profile
    end
  ''

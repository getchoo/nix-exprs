# this is a shell script that uses the new nix cli to emulate
# nix-collect-garbage
{
  lib,
  writeShellApplication,
  nix,
  fd,
}:
writeShellApplication {
  name = "nixgc";

  runtimeInputs = [nix fd];

  text = ''
    fd . /nix/var/nix/profiles /home/*/.local/state/nix/profiles -d 3 -t symlink -E '*-link' | while read -r profile; do
      nix profile wipe-history --profile "$profile" "$@"
    done
  '';
}
// {
  meta.platforms = lib.platforms.linux;
}

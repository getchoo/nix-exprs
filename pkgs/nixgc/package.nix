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

  runtimeInputs = [
    nix
    fd
  ];

  text = ''
    fd . /nix/var/nix/profiles /home/*/.local/state/nix/profiles -d 3 -t symlink -E '*-link' | while read -r profile; do
      nix profile wipe-history --profile "$profile" "$@"
    done
  '';

  meta = with lib; {
    description = "nix-collect-garbage, but with nix profile";
    maintainers = [ maintainers.getchoo ];
    platforms = platforms.linux;
  };
}

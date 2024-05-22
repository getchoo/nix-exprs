{writeShellApplication}:
writeShellApplication {
  name = "check-pr";
  text = ''
    _usage="
    usage: check-pr <owner/repo> <pr_id> [package]
    "

    [ "$#" -lt 2 ] && echo -n "$_usage" && exit 1

    nix run "github:$1?ref=pull/$2/head''${3:+#$3}"
  '';
}

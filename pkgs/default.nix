final: prev: let
  inherit (final) callPackage;
in {
  # original packages
  cartridges = callPackage ./cartridges.nix {};
  huion = callPackage ./huion.nix {};
  mommy = callPackage ./mommy.nix {};
  ## broken due to upstream adopting pnpm
  ## theseus = callPackage ./theseus.nix {};
  treefetch = callPackage ./treefetch.nix {};
  swhkd = callPackage ./swhkd {};
  vim-just = callPackage ./vim-just.nix {};
  xwaylandvideobridge = callPackage ./xwaylandvideobridge.nix {};

  # modified packages
  discord = prev.discord.override {withOpenASAR = true;};
  discord-canary = prev.discord-canary.override {withOpenASAR = true;};
}

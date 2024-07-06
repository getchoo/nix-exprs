{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells = {
        default = pkgs.mkShell {
          packages = [ self'.formatter ];

          inputsFrom = [ self'.packages.hello ];
        };
      };
    };
}

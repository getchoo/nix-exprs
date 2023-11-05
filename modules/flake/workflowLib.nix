lib: {
  self,
  platforms ? {
    "x86_64-linux" = {
      os = "ubuntu-latest";
      arch = "x64";
    };

    "aarch64-linux" = {
      os = "ubuntu-latest";
      arch = "aarch64";
    };

    "x86_64-darwin" = {
      os = "macos-latest";
      arch = "x64";
    };
  },
  ...
}: let
  inherit
    (lib)
    flatten
    getAttrs
    mapAttrsToList
    warn
    ;

  platforms' =
    platforms
    // {
      fallback = warn "an output in the job matrix is not supported!" {
        os = null;
        arch = null;
      };
    };

  mkMatrixMulti = systems: output:
    flatten (
      mapAttrsToList (
        system:
          mapAttrsToList (
            attr: _: {
              inherit (platforms'.${system} or platforms'.fallback) arch os;
              attr = "${output}.${system}.${attr}";
            }
          )
      )
      (getAttrs systems self.${output})
    );

  mkMatrixFlat = {
    output,
    suffix ? "",
  }:
    mapAttrsToList (
      attr: deriv: {
        inherit (platforms'.${deriv.pkgs.system} or platforms'.fallback) os arch;
        attr = "${output}.${attr}${suffix}";
      }
    )
    self.${output};

  mkMatrixSystem = output:
    mkMatrixFlat {
      inherit output;
      suffix = ".config.system.build.toplevel";
    };

  mkMatrixUser = mkMatrixFlat {
    output = "homeConfigurations";
    suffix = ".activationPackage";
  };
in {
  inherit
    mkMatrixMulti
    mkMatrixFlat
    mkMatrixSystem
    mkMatrixUser
    ;

  platforms = platforms';

  mkMatrix = {
    output,
    systems ? (builtins.attrNames platforms),
  }:
    {
      "nixosConfigurations" = mkMatrixSystem output;
      "darwinConfigurations" = mkMatrixSystem output;
      "homeConfigurations" = mkMatrixUser;
    }
    .${output}
    or (mkMatrixMulti systems output);
}

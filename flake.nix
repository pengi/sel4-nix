{
  description = "sel4 for pi4b";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/25.05";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
    }:
    utils.lib.eachSystem
      [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ]
      (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          microkit = import ./deps/microkit.nix { inherit system pkgs; };

        in
        {
          devShells.default = pkgs.mkShellNoCC rec {
            name = "sel4-shell";

            env.MICROKIT_SDK = microkit;

            nativeBuildInputs = with pkgs; [
              pkgsCross.aarch64-embedded.stdenv.cc.bintools
              pkgsCross.aarch64-embedded.stdenv.cc
              qemu
              gnumake
              curl

              microkit
            ];

            hardeningDisable = [ "all" ];
          };

          packages.default = import ./build.nix {
            inherit system pkgs microkit;
          };
        }
      );
}

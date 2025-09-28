{
  board ? "rpi4b_8gb"
}:
let

  nixpkgs = import <nixpkgs> { };
  microkit = import ./nix/microkit { inherit nixpkgs; };

  mk-sdk = microkit.sdk.${board}.debug;

  target = import ./example/target {
    inherit mk-sdk;
    mkDerivation = nixpkgs.stdenvNoCC.mkDerivation;
  };
in
target

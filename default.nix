let
  nixpkgs = import <nixpkgs> { };
  microkit = import ./nix/microkit { inherit nixpkgs; };

  mk-sdk = microkit.sdk.rpi4b_1gb.debug;

  target = import ./example/target {
    inherit mk-sdk;
    mkDerivation = nixpkgs.stdenvNoCC.mkDerivation;
  };
in
target

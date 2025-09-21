{
  nixpkgs ? import <nixpkgs> { },
  system ? builtins.currentSystem,
}:
let
  lib = import ./nixlib;
in
lib.derv {
  name = "sel4-pi4";
  inherit nixpkgs system;

  builder = ./builder.sh;

  tools = with nixpkgs; [
    pkgsCross.aarch64-embedded.stdenv.cc.bintools
    pkgsCross.aarch64-embedded.stdenv.cc
    qemu
    gnumake
    curl

    (import ./deps/microkit.nix {
      inherit nixpkgs system;
    })
  ];

  overlay = {
    src = ./src;

    sel4-rpi4 = (
      import ./deps/sel4-kernel.nix {
        inherit nixpkgs system;
        config = "AARCH64_bcm2711_verified";
      }
    );
  };
}

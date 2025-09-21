{
  nixpkgs ? import <nixpkgs> { },
  system ? builtins.currentSystem,
  config ? "AARCH64_bcm2711_verified",
}:
let
  lib = import ./nixlib;

  args =
    {
      "AARCH64_bcm2711_verified" = {
        bintools = nixpkgs.pkgsCross.aarch64-embedded.stdenv.cc.bintools;
        cc = nixpkgs.pkgsCross.aarch64-embedded.stdenv.cc;
        toolchain = "aarch64-none-elf-";
      };
      "X64_verified" = {
        bintools = nixpkgs.stdenv.cc.bintools;
        cc = nixpkgs.stdenv.cc;
        toolchain = "";
      };
    }
    .${config};

  microkit = import ./deps/microkit.nix {
    inherit nixpkgs system;
  };
in
lib.derv {
  name = "sel4-pi4";
  inherit nixpkgs system;

  builder = ./builder.sh;

  tools = with nixpkgs; [
    args.bintools
    args.cc

    #qemu

    gnumake

    # for makefiles when building
    libxml2
    gnused

    microkit
  ];

  overlay = {
    src = ./src;

    sel4 = (
      import ./deps/sel4-kernel.nix {
        inherit nixpkgs system;
        config = "AARCH64_bcm2711_verified";
      }
    );

    inherit microkit;
  };
}

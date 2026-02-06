{
  board ? "rpi4b_8gb",
}:
let

  nixpkgs = import <nixpkgs> { };

  #microkit = import ./nix/microkit { inherit nixpkgs; };
  #mk-sdk = microkit.sdk.${board}.debug;

  sel4 = import ./nix/sel4 { inherit nixpkgs; };

  qemu = nixpkgs.qemu.override {
  };

  target = sel4.custom_mcs {
    cc = nixpkgs.pkgsCross.riscv64-embedded.stdenv.cc;
    plat = "qemu-riscv-virt";
    deps = [
      qemu
    ];
  };
in
{
  #sel4-star64 = sel4.custom_mcs {
  #  cc = nixpkgs.pkgsCross.riscv64-embedded.stdenv.cc;
  #  plat = "star64";
  #};

  sel4 = target;
  qemu = qemu;
}

{
  plat ? "qemu-riscv-virt", # "star64",
  nixpkgs ? import <nixpkgs> { },
}:
let
  sel4 = import ./nix/sel4 { inherit nixpkgs; };

  plat_conf =
    if (builtins.substring 0 4 plat) == "qemu" then
      {
        deps = [
          nixpkgs.qemu
        ];
        targets = {
          qemu = nixpkgs.qemu;
        };
      }
    else
      {
        deps = [ ];
        targets = {
        };
      };

  target = sel4.custom_mcs {
    cc = nixpkgs.pkgsCross.riscv64-embedded.stdenv.cc;
    deps = [ ] ++ plat_conf.deps;
    plat = plat;
  };
in
{

  sel4 = target;
  cc = target.cc;
}
// plat_conf.targets

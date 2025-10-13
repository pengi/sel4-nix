{ nixpkgs }:
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

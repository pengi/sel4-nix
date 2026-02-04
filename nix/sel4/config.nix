{ nixpkgs }:
let
  toolchain_aarch64 = {
    bintools = nixpkgs.pkgsCross.aarch64-embedded.stdenv.cc.bintools;
    cc = nixpkgs.pkgsCross.aarch64-embedded.stdenv.cc;
    toolchain = "aarch64-none-elf-";
  };
  toolchain_armhf = {
    bintools = nixpkgs.pkgsCross.armhf-embedded.stdenv.cc.bintools;
    cc = nixpkgs.pkgsCross.armhf-embedded.stdenv.cc;
    toolchain = "arm-none-eabihf-";
  };
  toolchain_riscv64 = {
    bintools = nixpkgs.pkgsCross.riscv64-embedded.stdenv.cc.bintools;
    cc = nixpkgs.pkgsCross.riscv64-embedded.stdenv.cc;
    toolchain = "riscv64-none-elf-";
  };
  toolchain_x86_64 = {
    bintools = nixpkgs.pkgsCross.x86_64-embedded.stdenv.cc.bintools;
    cc = nixpkgs.pkgsCross.x86_64-embedded.stdenv.cc;
    toolchain = "x86_64-elf-";
  };
in
{
  "AARCH64_bcm2711_verified" = toolchain_aarch64;
  "AARCH64_hikey_verified" = toolchain_aarch64;
  "AARCH64_imx8mm_verified" = toolchain_aarch64;
  "AARCH64_imx8mq_verified" = toolchain_aarch64;
  "AARCH64_imx93_verified" = toolchain_aarch64;
  "AARCH64_maaxboard_verified" = toolchain_aarch64;
  "AARCH64_odroidc2_verified" = toolchain_aarch64;
  "AARCH64_odroidc4_verified" = toolchain_aarch64;
  "AARCH64_rockpro64_verified" = toolchain_aarch64;
  "AARCH64_tqma_verified" = toolchain_aarch64;
  "AARCH64_tx1_verified" = toolchain_aarch64;
  "AARCH64_ultra96v2_verified" = toolchain_aarch64;
  "AARCH64_verified" = toolchain_aarch64;
  "AARCH64_zynqmp_verified" = toolchain_aarch64;
  "ARM_am335x_verified" = toolchain_armhf;
  "ARM_bcm2837_verified" = toolchain_armhf;
  "ARM_exynos4_verified" = toolchain_armhf;
  "ARM_exynos5410_verified" = toolchain_armhf;
  "ARM_exynos5422_verified" = toolchain_armhf;
  "ARM_hikey_verified" = toolchain_armhf;
  "ARM_HYP_exynos5_verified" = toolchain_armhf;
  "ARM_HYP_exynos5410_verified" = toolchain_armhf;
  "ARM_HYP_verified" = toolchain_armhf;
  "ARM_imx8mm_verified" = toolchain_armhf;
  "ARM_MCS_verified" = toolchain_armhf;
  "ARM_omap3_verified" = toolchain_armhf;
  "ARM_tk1_verified" = toolchain_armhf;
  "ARM_verified" = toolchain_armhf;
  "ARM_zynq7000_verified" = toolchain_armhf;
  "ARM_zynqmp_verified" = toolchain_armhf;
  "RISCV64_MCS_verified" = toolchain_riscv64;
  "RISCV64_verified" = toolchain_riscv64;
  "X64_verified" = toolchain_x86_64;
}

